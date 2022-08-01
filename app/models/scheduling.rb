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
  # validates_presence_of :units, message: "or minutes, any one must be present.", if: proc { |obj| obj.minutes.blank? }
  # validates_absence_of :units, message: "or minutes, only one must be present.", if: proc { |obj| obj.minutes.present? }

  # validate :validate_time
  validate :validate_past_appointments, on: :create
  validate :validate_units, on: :create
  # validate :validate_staff, on: :create
  # validate :validate_units_and_minutes
  
  enum status: {Scheduled: 0, Rendered: 1, Auth_Pending: 2, Non_Billable: 3, Duplicate: 4, Error: 5, Client_Cancel_Greater_than_24_h: 6, Client_Cancel_Less_than_24_h: 7, Client_No_Show: 8, Staff_Cancellation: 9, Staff_Cancellation_Due_To_Illness: 10, Cancellation_Related_to_COVID: 11, Unavailable: 12, Inclement_Weather_Cancellation: 13}

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
    return if self.client_enrollment_service.blank?

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

  # def validate_units_and_minutes
  #   if self.units.present? && self.minutes.present?
  #     minutes = self.units*15
  #     errors.add(:scheduling, "The units/minutes are wrong. 1 unit is equivalent to 15 minutes, and vice versa.") if minutes != self.minutes
  #   end
  # end

  def set_units_and_minutes
    if self.units.present? && self.minutes.blank?
      self.minutes = self.units*15
    elsif self.minutes.present? && self.units.blank?
      rem = self.minutes%15
      if rem == 0
        self.units = self.minutes/15
      elsif rem < 8
        self.units = (self.minutes - rem)/15
      else
        self.units = (self.minutes + 15 - rem)/15
      end
    end 
  end
  # end of private
end
