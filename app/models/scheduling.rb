require 'audited.rb'
DATE_RANGE_QUERY = 'date < ? OR (date = ? AND end_time < ?)'.freeze

class Scheduling < ApplicationRecord
  audited only: %i[start_time end_time units date status], on: :update
  has_associated_audits

  belongs_to :staff, optional: true
  belongs_to :client_enrollment_service, optional: true
  has_many :soap_notes, dependent: :destroy
  has_many :scheduling_change_requests, dependent: :destroy

  attr_accessor :user, :error_msgs

  validates_presence_of :date, :start_time, :end_time, :status

  # validate :validate_time
  validate :validate_past_appointments, on: :create
  validate :validate_units, on: :create
  # validate :validate_draft_appointments, on: :create
  # validate :validate_staff, on: :create
  
  enum status: { scheduled: 'scheduled', rendered: 'rendered', auth_pending: 'auth_pending', non_billable: 'non_billable', 
                 duplicate: 'duplicate', error: 'error', client_cancel_greater_than_24_h: 'client_cancel_greater_than_24_h', 
                 client_cancel_less_than_24_h: 'client_cancel_less_than_24_h', client_no_show: 'client_no_show', 
                 staff_cancellation: 'staff_cancellation', staff_cancellation_due_to_illness: 'staff_cancellation_due_to_illness', 
                 cancellation_related_to_covid: 'cancellation_related_to_covid', unavailable: 'unavailable', 
                 inclement_weather_cancellation: 'inclement_weather_cancellation', draft: 'draft' }

  #TODO: uncoment this line after understand why the update method is called three times from the frontend
  #after_update :mail_change_appoitment   

  before_save :set_units_and_minutes

  serialize :unrendered_reason, Array

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

      schedulings = (Constant.zero..(range[:end].to_date - range[:start].to_date).to_i).map { |index|
        fill_schedules(schedule, (range[:start].to_date + index.day).strftime('%Y-%m-%d'), current_user.id)
      }
      check_recurrence(schedulings)
    end

    def pattern_recurrences(option, schedule, current_user)
      error_msgs = []
      error_msgs.push('we have an error, you must add a recurring appointment pattern') if option[:recurrence].nil? || option[:quantity].nil? || option[:quantity].to_i.zero? 
      return reponse_recurrence(error_msgs.uniq) if error_msgs.any?

      schedulings = fill_recurrences(option, schedule, current_user)
      check_recurrence(schedulings)
    end

    def fill_recurrences(option, schedule, current_user)
      calcule_dates = fetch_date(option, option[:recurrence] == Constant.monthly || option[:recurrence] == Constant.yearly ? month_year_recurrences(option) : nil) 
      (Constant.zero..(calcule_dates.present? ? calcule_dates&.count : recurrences)).each_with_object([]) do |index, array|
        break array if index == (calcule_dates.present? ? calcule_dates&.count : recurrences)

        array << fill_schedules(schedule, calcule_dates.present? ? calcule_dates[index].strftime('%Y-%m-%d') : Date.today + index.day, current_user.id)
      end
    end

    def month_year_recurrences(option)
      cont_recurrences = Constant.zero
      date_initial = Date.today

      recurrences = option[:quantity].to_i
      
      (Constant.zero..recurrences).each do |index|
        break if index == recurrences

        calcule_date = option[:recurrence] == Constant.monthly ? date_initial + index.month : date_initial + index.year
        if option[:recurrence] == Constant.monthly
          if calcule_date.beginning_of_month.cweek < date_initial.cweek
            cont_recurrences += calcule_date.at_end_of_month.cweek - calcule_date.beginning_of_month.cweek - (date_initial.cweek - calcule_date.beginning_of_month.cweek)
          else
            cont_recurrences += (calcule_date.at_end_of_month.cweek - calcule_date.beginning_of_month.cweek) * recurrences
          end
        elsif option[:recurrence] == Constant.yearly
          cont_recurrences += calcule_date.at_end_of_year.year <= date_initial.year ? calcule_date.at_end_of_year.cweek - date_initial.cweek : calcule_date.at_end_of_year.cweek
        end
      end
      
      cont_recurrences
    end

    def fetch_date(option, month_yearly = nil)
      dates = []
      recurrences = month_yearly.present? ? month_yearly : option[:quantity].to_i
      (Constant.zero..recurrences).each do |index|
        break if index == recurrences

        date_initial = Date.today.beginning_of_week + index.week
        option[:days] = Constant.all_days if option[:days].empty?
        option[:days].each do |number_day|
          dates.push(calcule_day(date_initial, recurrences, Constant.days_name[number_day.to_i]))
        end
      end

      dates
    end

    def calcule_day(date_initial, recurrences, name_day)
      finish_date = date_initial + Constant.days["#{name_day}"].day
      finish_date < Date.today ? finish_date + recurrences.week : finish_date
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
        error_msgs.push(I18n.t('.activerecord.models.scheduling.errors.range').capitalize) if scheduling[:date].to_date > client_enrollment_service.end_date.to_date
        error_msgs.push(I18n.t('.activerecord.models.scheduling.errors.units_blank').capitalize) if scheduling[:units].nil?
        error_msgs.push(I18n.t('.activerecord.models.scheduling.errors.limit_autorization').capitalize) if cont_units > client_enrollment_service.units
        error_msgs.push(I18n.t('.activerecord.models.scheduling.errors.any_appointment').capitalize) if self.any? && check_date_available(scheduling[:date], scheduling[:start_time].delete!('^0-9:'), scheduling[:end_time].delete!('^0-9:')).any?
        error_msgs.push(I18n.t('.activerecord.models.scheduling.errors.limit_recurrence').capitalize) if cont_limit > Constant.limit_appointment_recurrence
        cont_limit += Constant.one
      end
      
      reponse_recurrence(error_msgs.uniq, error_msgs.any? ? Constant.empty : create_recur(schedulings))
    end

    def check_date_available(date, start_time, end_time)
      where(date: date, start_time: start_time.., end_time: ..end_time)
    end

    def create_recur(schedulings)
      schedulings.each { |scheduling| Scheduling.create scheduling }
    end

    def reponse_recurrence(errors, response_successfully = [])
      if errors.present?
        {status: 'errors', data: errors}
      else
        {status: 'success', data: response_successfully}
      end
    end
  end
  
  def mail_change_appoitment
    StaffMailer.schedule_update(self).deliver
  end

  def set_status_and_rendered_at(schedule)
    if schedule&.client_enrollment_service&.service&.is_early_code? 
      status = 'auth_pending'
      rendered_at = nil
    else
      status = 'rendered'
      rendered_at = Time.current
    end
    [status, rendered_at]
  end
  
  def notification_draft_appointment
    params = {
      message: I18n.t('.notification.draft_appointment.message'),
      notification_url: "#{ENV["DOMAIN"]}#{ENV["SCHEDULING_PATH"]}#{self.id}",
      affected_id: self.id,
      affected: self.class.name
    }
    DraftNotification.with(params).deliver(recipients)
  end

  def recipients
    recipients = [staff]
    recipients << Staff.by_creator(creator_id)
    recipients << Staff.active.joins(:role, :clinics).where('clinics.id': staff.staff_clinics.home_clinic.first[:clinic_id], 'roles.name': [Constant.roles['ed']]).to_ary
    recipients.flatten
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
    user = User.find_by(id: self.creator_id)
    return if user&.role_name=='super_admin' || date.blank?

    if user&.role_name == 'executive_director' || user&.role_name == 'Clinical Director' || user&.role_name == 'client_care_coordinator'
      errors.add(:scheduling, 'You are not authorized to create appointments for 3 days ago.') if date < Date.today - Constant.third.days
    elsif user&.role_name == 'bcba'
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

  def validate_draft_appointments
    user = User.by_creator(creator_id)
    return true if draft? && (user.role_name == Constant.roles['ccc'] || user.role_name == Constant.roles['cd'])

    errors.add(:draft, I18n.t('activerecord.models.scheduling.validate_draft'))
  end

  def self.transform_statuses(action_type, role)
    statuses.map do |type, _|
      next if (type == 'draft') && (action_type == 'edit' || ![Constant.roles['ccc'],Constant.roles['cd']].include?(role))


      { 'value' => type, 'title'=> I18n.t("activerecord.attributes.scheduling.statuses.#{type}").capitalize }
    end.compact
  end
end
