require 'audited.rb'
DATE_RANGE_QUERY = 'date < ? OR (date = ? AND end_time < ?)'.freeze

class Scheduling < ApplicationRecord
  audited only: %i[start_time end_time units date status], on: :update

  belongs_to :staff, optional: true
  belongs_to :client_enrollment_service, optional: true
  has_many :soap_notes, dependent: :destroy
  has_many :scheduling_change_requests, dependent: :destroy

  attr_accessor :user

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
  scope :partially_rendered_schedules, ->{ where(status: 'Auth_Pending', rendered_at: nil)}
  scope :past_60_days_schedules, ->{ where('date>=? AND date<?', (Time.current-60.days).strftime('%Y-%m-%d'), Time.current.strftime('%Y-%m-%d')) }
  scope :without_staff, ->{ where(staff_id: nil) }
  scope :with_staff, ->{ where.not(staff_id: nil) }
  scope :with_client, ->{ where.not(client_enrollment_service_id: nil) }
  scope :without_client, ->{ where(client_enrollment_service_id: nil) }
  scope :with_active_client, ->{ where('clients.status = ?', 0) }
  scope :post_30_may_schedules, ->{ where('date>? and date <?', '2022-05-30', Time.current.strftime('%Y-%m-%d')) }
  scope :within_dates, ->(start_date, end_date){ where('date>=? AND date<=?', start_date, end_date) }
  scope :completed_todays_schedulings, ->{ where('date = ? AND end_time < ?', Time.current.to_date, Time.current.strftime('%H:%M'))}

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
    return if self.user.role_name=='super_admin' || self.date.blank?

    if self.user.role_name=='executive_director' || self.user.role_name=='Clinical Director' || self.user.role_name=='client_care_coordinator'
      errors.add(:scheduling, 'You are not authorized to create appointments for 3 days ago.') if self.date<(Time.current.to_date-3)
    elsif self.user.role_name=='bcba'
      errors.add(:scheduling, 'You are not authorized to create appointment past 24 hrs.') if self.date<(Time.current-1.day).to_date || (self.date==(Time.current-1.day).to_date && self.start_time<Time.current.strftime('%H:%M'))
    elsif (self.date<Time.current.to_date || (self.date==Time.current.to_date && self.start_time<=Time.current.strftime('%H:%M')))
      errors.add(:scheduling, 'You are not authorized to create appointment in past.')
    end
  end

  def validate_units
    return if (self.client_enrollment_service.blank? || (self.scheduled? && self.rendered? && self.status.auth_pending?))

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
