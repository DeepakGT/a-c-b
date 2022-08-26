require 'audited.rb'
DATE_RANGE_QUERY = 'date < ? OR (date = ? AND end_time < ?)'.freeze

class Scheduling < ApplicationRecord
  audited only: %i[start_time end_time units date status], on: :update

  belongs_to :staff, optional: true
  belongs_to :client_enrollment_service, optional: true
  has_many :soap_notes, dependent: :destroy
  has_many :scheduling_change_requests, dependent: :destroy

  attr_accessor :user, :error_msgs

  validates_presence_of :date, :start_time, :end_time, :status

  # validate :validate_time
  validate :validate_past_appointments, on: :create
  validate :validate_units, on: :create
  # validate :validate_staff, on: :create
  
  enum status: { scheduled: 'scheduled', rendered: 'rendered', auth_pending: 'auth_pending', non_billable: 'non_billable', 
                 duplicate: 'duplicate', error: 'error', client_cancel_greater_than_24_h: 'client_cancel_greater_than_24_h', 
                 client_cancel_less_than_24_h: 'client_cancel_less_than_24_h', client_no_show: 'client_no_show', 
                 staff_cancellation: 'staff_cancellation', staff_cancellation_due_to_illness: 'staff_cancellation_due_to_illness', 
                 cancellation_related_to_covid: 'cancellation_related_to_covid', unavailable: 'unavailable', 
                 inclement_weather_cancellation: 'inclement_weather_cancellation'}

  before_save :set_units_and_minutes

  serialize :unrendered_reason, Array

  #scopes
  scope :by_status, ->{ where('lower(schedulings.status) = ?','scheduled') }
  scope :with_rendered_or_scheduled_as_status, ->{ where('lower(schedulings.status) = ? OR lower(schedulings.status) = ?', 'scheduled', 'rendered') }
  scope :completed_scheduling, ->{ where('date < ?',Time.current.to_date) }
  scope :todays_schedulings, ->{ where('date = ?',Time.current.to_date) }
  scope :scheduled_scheduling, ->{ where('date >= ?',Time.current.to_date) }
  scope :unrendered_schedulings, ->{ where(rendered_at: nil) }
  scope :with_units, ->{ where.not(units: nil) }
  scope :with_minutes, ->{ where.not(minutes: nil) }
  scope :by_client_and_service, ->(client_id, service_id){ joins(client_enrollment_service: :client_enrollment).where('client_enrollments.client_id': client_id, 'client_enrollment_service.service_id': service_id)}
  scope :by_client_ids, ->(client_ids){ where('client_enrollments.client_id': client_ids) }
  scope :by_staff_ids, ->(staff_ids){ where(staff_id: staff_ids) }
  scope :by_service_ids, ->(service_ids){ where('client_enrollment_service.service_id': service_ids) }
  scope :by_client_clinic, ->(location_id) { where('clients.clinic_id': location_id) }
  scope :by_staff_clinic, ->(location_id) { where('staff_clinics.clinic_id': location_id) }
  scope :by_staff_home_clinic, ->(location_id) { where('staff_clinics.clinic_id = ? AND staff_clinics.is_home_clinic = ?', location_id, true) }
  scope :on_date, ->(date){ where(date: date) }
  scope :exceeded_24_h_scheduling, ->{ where(DATE_RANGE_QUERY, Time.current.to_date-1, Time.current.to_date-1, Time.current.strftime('%H:%M')) }
  scope :exceeded_3_days_scheduling, ->{ where(DATE_RANGE_QUERY, Time.current.to_date-3, Time.current.to_date-3, Time.current.strftime('%H:%M')) }
  scope :exceeded_5_days_scheduling, ->{ where(DATE_RANGE_QUERY, Time.current.to_date-5, Time.current.to_date-5, Time.current.strftime('%H:%M')) }
  scope :partially_rendered_schedules, ->{ where(status: 'auth_pending', rendered_at: nil)}
  scope :past_60_days_schedules, ->{ where('date>=? AND date<?', (Time.current-60.days).strftime('%Y-%m-%d'), Time.current.strftime('%Y-%m-%d')) }
  scope :without_staff, ->{ where(staff_id: nil) }
  scope :with_staff, ->{ where.not(staff_id: nil) }
  scope :with_client, ->{ where.not(client_enrollment_service_id: nil) }
  scope :without_client, ->{ where(client_enrollment_service_id: nil) }
  scope :with_active_client, ->{ where('clients.status = ?', 0) }
  scope :post_30_may_schedules, ->{ where('date>? and date <?', '2022-05-30', Time.current.strftime('%Y-%m-%d')) }
  scope :within_dates, ->(start_date, end_date){ where('date>=? AND date<=?', start_date, end_date) }
  scope :completed_todays_schedulings, ->{ where('date = ? AND end_time < ?', Time.current.to_date, Time.current.strftime('%H:%M'))}
  scope :future_schedulings, ->{where('date > ?', Time.current.strftime('%Y-%m-%d')).or(where('date = ? AND start_time >= ?', Time.current.strftime('%Y-%m-%d'), Time.current.strftime('%H:%M')))}
  scope :by_appointment_office, ->(clinic_ids){ where(appointment_office_id: clinic_ids) }

  def calculate_units(minutes)
    rem = minutes%15
    if rem == 0
      minutes/15
    elsif rem < 8
      (minutes - rem)/15
    else
      (minutes + 15 - rem)/15
    end
  end

  class << self
    def range_recurrences(range, schedule, current_user)
      error_msgs = []
      error_msgs.push('we have an error, you should add the dates for the recurring range option') if range[:start].nil? || range[:end].nil?
      error_msgs.push("the start date must be greater than or equal to today's date") if range[:start].to_date < Date.today
      return reponse_recurrence(error_msgs.uniq, Constant.empty) if error_msgs.any?

      schedulings = (Constant.zero..(range[:end].to_date - range[:start].to_date).to_i).each_with_object([]) do |index, array|
        array << fill_schedules(schedule, (range[:start].to_date + index.day).strftime('%Y-%m-%d'), current_user.id)
      end

      check_recurrence(schedulings)
    end

    def pattern_recurrences(option, schedule, current_user)
      error_msgs = []
      error_msgs.push('we have an error, you must add a recurring appointment pattern') if option[:daily] == false && option[:weekly] == false && option[:monthly] == false && option[:yearly] == false  
      return reponse_recurrence(error_msgs.uniq, Constant.empty) if error_msgs.any?

      schedulings = check_option(option, schedule, current_user)
      check_recurrence(schedulings)
    end

    def check_option(option, schedule, current_user)
      option_select = nil
      if option[:daily]
        option_select = fill_recurrences(option[:daily_recurrences], schedule, current_user, option)
      elsif option[:weekly]
        option_select = fill_recurrences(option[:weekly_recurrences], schedule, current_user, option)
      elsif option[:monthly]
        option_select = fill_recurrences(option[:monthly_recurrences], schedule, current_user, option)
      elsif option[:yearly]
        option_select = fill_recurrences(option[:yearly_recurrences], schedule, current_user, option)
      end
      option_select
    end

    def fill_recurrences(recurrences, schedule, current_user, option)
      calcule_dates = calcule_dates(recurrences, option)


      (Constant.zero..(calcule_dates.present? ? calcule_dates&.count : recurrences)).each_with_object([]) do |index, array|
        break array if index == (calcule_dates.present? ? calcule_dates&.count : recurrences)

        array << fill_schedules(schedule, calcule_dates.present? ? calcule_dates[index].strftime('%Y-%m-%d') : Date.today + index.day, current_user.id)
      end
    end

    def calcule_dates(recurrences, option)
      calcule_dates = nil

      if option[:daily] && option[:daily_days]&.any?
        calcule_dates = fetch_date(option[:daily_days], recurrences)
      elsif option[:weekly]
        calcule_dates = fetch_date(option[:weekly_days]&.any? ? option[:weekly_days] : Constant.all_days, recurrences)
      elsif option[:monthly]
        calcule_dates = fetch_date(option[:monthly_days]&.any? ? option[:monthly_days] : Constant.all_days, month_year_recurrences(option))
      elsif option[:yearly]
        calcule_dates = fetch_date(option[:yearly_days]&.any? ? option[:yearly_days] : Constant.all_days, month_year_recurrences(option))
      end

      calcule_dates
    end

    def month_year_recurrences(option)
      cont_recurrences = Constant.zero
      date_initial = Date.today

      recurrences = if option[:monthly]
                      option[:monthly_recurrences]
                    elsif option[:yearly]
                      option[:yearly_recurrences]
                    end
      
     (Constant.zero..recurrences).each do |index|
        break if index == recurrences

        calcule_date = option[:monthly] ? date_initial + index.month : date_initial + index.year
        if option[:monthly]
          if calcule_date.beginning_of_month.cweek < date_initial.cweek
            cont_recurrences += calcule_date.at_end_of_month.cweek - calcule_date.beginning_of_month.cweek - (date_initial.cweek - calcule_date.beginning_of_month.cweek)
          else
            cont_recurrences += calcule_date.at_end_of_month.cweek - calcule_date.beginning_of_month.cweek
          end
        elsif option[:yearly]
          cont_recurrences += calcule_date.at_end_of_year.cweek - date_initial.cweek
        end
      end
    
      cont_recurrences
    end

    def fetch_date(number_days, recurrences)
      dates = []
      (Constant.zero..recurrences).each do |index|
        break if index == recurrences

        date_initial = Date.today.beginning_of_week + index.week
        number_days.each do |number_day|
          case number_day.to_i
          when Constant.days['monday']
            dates.push(calcule_day(date_initial, recurrences, 'monday'))
          when Constant.days['tuesday']
            dates.push(calcule_day(date_initial, recurrences, 'tuesday'))
          when Constant.days['wednesday']
            dates.push(calcule_day(date_initial, recurrences, 'wednesday'))
          when Constant.days['thursday']
            dates.push(calcule_day(date_initial, recurrences, 'thursday'))
          when Constant.days['friday']
            dates.push(calcule_day(date_initial, recurrences, 'friday'))
          when Constant.days['saturday']
            dates.push(calcule_day(date_initial, recurrences, 'saturday'))
          when Constant.days['sunday']
            dates.push(calcule_day(date_initial, recurrences, 'sunday'))
          end
        end
      end

      dates
    end

    def calcule_day(date_initial, recurrences, name_day)
      date = nil
      finish_date = date_initial + Constant.days["#{name_day}"].day
      
      if finish_date < Date.today
        date = finish_date + recurrences.week
      else
        date = finish_date
      end

      date
    end

    def fill_schedules(schedule, date, uid)
      {
        status: schedule[:status], date: date,
        start_time: schedule[:start_time], end_time: schedule[:end_time], units: schedule[:units],
        minutes: schedule[:minutes], client_enrollment_service_id: schedule[:client_enrollment_service_id],
        cross_site_allowed: schedule[:cross_site_allowed], service_address_id: schedule[:service_address_id],
        creator_id: uid, staff_id: schedule[:staff_id]
      }
    end

    def check_recurrence(schedulings)
      error_msgs = []
      cont_units = Constant.zero
      cont_limit = Constant.zero
      schedulings.each do |scheduling|
        client_enrollment_service = ClientEnrollmentService.find_by id: scheduling[:client_enrollment_service_id]
        cont_units += scheduling[:units].to_i if scheduling[:units].present? && scheduling[:units].to_i.positive?
        error_msgs.push('range of recurrences exceeds one authorization') if scheduling[:date].to_date > client_enrollment_service.end_date.to_date
        error_msgs.push('Units may not be blank or empty') if scheduling[:units].nil?
        error_msgs.push('over pass authorization units') if cont_units > client_enrollment_service.units
        error_msgs.push('an appointment is already scheduled, try again to reschedul  e it') if self.any? && check_date_available(scheduling[:date], scheduling[:start_time], scheduling[:end_time]).any?
        error_msgs.push('limit reached, try again') if cont_limit > Constant.limit_appointment_recurrence
        cont_limit += Constant.one
      end
      
      reponse_recurrence(error_msgs.uniq, error_msgs.any? ? Constant.empty : create_all(schedulings))
    end

    def check_date_available(date, start_time, end_time)
      where(date: date).where('start_time >= ? and end_time <= ? ', start_time, end_time)
    end

    def create_all(schedulings)
      schedulings.each { |scheduling| Scheduling.create scheduling }
    end

    def reponse_recurrence(errors, response_successfully)
      if errors.any?
        {status: 'errors', data: errors}
      else
        {status: 'success', data: response_successfully}
      end
    end
  end
  
  private

  # def validate_time
  #   possible_schedules = Scheduling.where.not(id: self.id)
  #   same_day_schedules = possible_schedules.where(staff_id: self.staff_id, client_enrollment_service_id: self.client_enrollment_service_id, date: self.date)
  #   return if same_day_schedules.blank?
    
  #   overlapping_time_schedules = same_day_schedules.where("start_time <= ? AND end_time >= ?", self.start_time, self.end_time)
  #                                                  .or(same_day_schedules.where("start_time > ? AND end_time < ?", self.start_time, self.end_time))
  #                                                  .or(same_day_schedules.where("start_time < ? AND end_time > ?", self.start_time, self.start_time))
  #                                                  .or(same_day_schedules.where("start_time < ? AND end_time > ?", self.end_time, self.end_time))
  #   return if overlapping_time_schedules.blank?
    
  #   errors.add(:scheduling, 'must not have overlapping time for same staff, client and service on same date')
  # end

  def validate_past_appointments
    rser = User.find_by(id: creator_id)
    return if user.role_name=='super_admin' || date.blank?

    if user.role_name == 'executive_director' || user.role_name == 'Clinical Director' || user.role_name == 'client_care_coordinator'
      errors.add(:scheduling, 'You are not authorized to create appointments for 3 days ago.') if date < Date.today - Constant.third.days
    elsif user.role_name == 'bcba'
      errors.add(:scheduling, 'You are not authorized to create appointment past 24 hrs.') if date < Date.today - Constant.one.day || (date == Date.today - Constant.one.day && start_time < Time.current.strftime('%H:%M'))
    elsif (date < Date.today || (date == Date.today && start_time <= Time.current.strftime('%H:%M')))
      errors.add(:scheduling, 'You are not authorized to create appointment in past.')
    end
  end

  def validate_units
    return if (self.client_enrollment_service.blank? || (!self.scheduled? && !self.rendered? && !self.auth_pending?))

    schedules = Scheduling.where.not(id: self.id).where(client_enrollment_service_id: self.client_enrollment_service.id).with_rendered_or_scheduled_as_status
    completed_schedules = schedules.completed_scheduling
    scheduled_schedules = schedules.scheduled_scheduling
    used_units = completed_schedules.with_units.pluck(:units).sum
    scheduled_units = scheduled_schedules.with_units.pluck(:units).sum
    
    errors.add(:units, "left for authorization are not enough to create this appointment.") if self.units.present? && self.client_enrollment_service.units.present? && (self.units>(self.client_enrollment_service.units-(used_units+scheduled_units)))
  end

  # def validate_staff
  #   schedules = self.staff&.schedulings&.unrendered_schedulings&.exceeded_5_days_scheduling
  #   if schedules.any?
  #     errors.add(:staff, 'No further appointments can be created for given staff unless exceeded 5 days past appointments are rendered.')
  #   end
  # end

  def set_units_and_minutes
    if self.units.present? && self.minutes.blank?
      self.minutes = self.units*15
    elsif self.minutes.present? && self.units.blank?
      self.units = self.calculate_units(self.minutes)
    else
      if self.units.blank? && self.minutes.blank? && self.start_time.present? && self.end_time.present?
        self.minutes = (self.end_time.to_time - self.start_time.to_time) / 1.minutes
        self.units = self.calculate_units(self.minutes)
      else
        self.units ||= 0
        self.minutes ||= 0
      end
    end 
  end
  # end of private
end
