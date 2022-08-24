DATE_FORMAT = '%Y-%m-%d'.freeze

class ClientEnrollmentService < ApplicationRecord
  belongs_to :client_enrollment
  belongs_to :service

  has_many :service_providers, class_name: :ClientEnrollmentServiceProvider, dependent: :destroy
  has_many :staff, through: :service_providers
  has_many :schedulings, dependent: :destroy

  accepts_nested_attributes_for :service_providers

  validate :validate_service_providers
  # validate :validate_units_and_minutes
  validate :validate_count_of_units, on: :update
  validate :validate_dates

  before_validation :set_units_and_minutes

  scope :by_client, ->(client_ids){ joins(:client_enrollment).where('client_enrollments.client_id': client_ids) }
  scope :by_date, ->(date){ where('start_date <= ? AND end_date >= ?', date, date) }
  scope :by_staff, ->(staff_id){ joins(:service_providers).where('client_enrollment_service_providers.staff_id': staff_id) }
  scope :by_service, ->(service_ids){ where(service_id: service_ids) }
  scope :by_staff_qualifications, ->(staff_qualification_ids) { where('service_qualifications.qualification_id': staff_qualification_ids) }
  scope :by_service_with_no_qualification, ->{select("client_enrollment_services.*").group("client_enrollment_services.id").having("count(service_qualifications.*) = ?",0)}
  scope :by_bcba_ids, ->(bcba_ids){ joins(client_enrollment: :client).where('clients.bcba_id': bcba_ids) }
  scope :about_to_expire, ->{ where('end_date>=? AND end_date<=?', Time.current.to_date, (Time.current.to_date+9)) }
  scope :by_client_enrollment, ->(client_enrollment_id){ where(client_enrollment_id: client_enrollment_id)}
  scope :by_funding_source, ->(funding_source_id){ where('client_enrollments.funding_source_id': funding_source_id) }
  scope :expire_in_5_days, ->{ where('end_date >= ? AND end_date<=?', Time.current.to_date, (Time.current.to_date+4))}
  scope :started_between_5_to_20_days_past_from_today, ->{where('start_date>=? AND start_date<=?', (Time.current-20.days).strftime(DATE_FORMAT), (Time.current-5.days).strftime(DATE_FORMAT))}
  scope :started_between_21_to_60_days_past_from_today, ->{where('start_date>=? AND start_date<=?', (Time.current-60.days).strftime(DATE_FORMAT), (Time.current-21.days).strftime(DATE_FORMAT))}
  scope :except_self, ->(self_id){ where.not(id: self_id) }
  scope :active, ->{ where('end_date >= ?', Time.current.strftime(DATE_FORMAT)) }
  scope :before_date, ->(date){ where('start_date < ?', date.to_time.strftime(DATE_FORMAT)) }
  scope :expired, ->{ where('end_date < ?', Time.current.strftime(DATE_FORMAT))}
  scope :by_unassigned_appointments_allowed, -> { where('services.is_unassigned_appointment_allowed = ?', true)}
  scope :excluding_early_codes, -> { joins(:service).where.not('services.is_early_code': true)}
  scope :excluding_97151_service, -> { where.not('services.display_code': '97151') }
  scope :including_early_codes, -> { where('services.is_early_code': true)}
  scope :with_funding_sources, ->{ where.not('client_enrollments.funding_source_id': nil) }
  scope :not_expired_before_30_days, ->{ where.not('end_date <= ?', (Time.current.to_date-30))}
  
  def used_units
    schedules = self.schedulings.where(status: 'Rendered')
    if schedules.any?
      used_units = schedules.with_units.pluck(:units).sum.to_f
      used_units = 0 if used_units.blank?
    else
      used_units = 0
    end
    used_units
  end

  def used_minutes
    schedules = self.schedulings.where(status: 'Rendered')
    if schedules.any?
      used_minutes = schedules.with_minutes.pluck(:minutes).sum.to_f
      used_minutes = 0 if used_minutes.blank?
    else
      used_minutes = 0
    end
    used_minutes
  end

  def scheduled_units
    schedules = self.schedulings.by_status
    if schedules.any?
      scheduled_units = schedules.with_units.pluck(:units).sum.to_f
      scheduled_units = 0 if scheduled_units.blank?
    else
      scheduled_units = 0
    end
    scheduled_units
  end

  def scheduled_minutes
    schedules = self.schedulings.by_status
    if schedules.any?
      scheduled_minutes = schedules.with_minutes.pluck(:minutes).sum.to_f
      scheduled_minutes = 0 if scheduled_minutes.blank?
    else
      scheduled_minutes = 0
    end
    scheduled_minutes
  end

  def left_units
    used_units = self.used_units.present? ? self.used_units.to_f : 0
    scheduled_units = self.scheduled_units.present? ? self.scheduled_units.to_f : 0
    self.units.present? ? (self.units-(used_units+scheduled_units)).to_f : 0
  end

  def left_minutes
    used_minutes = self.used_minutes.present? ? self.used_minutes.to_f : 0
    scheduled_minutes = self.scheduled_minutes.present? ? self.scheduled_minutes.to_f : 0
    self.minutes.present? ? (self.minutes-(used_minutes+scheduled_minutes)).to_f : 0
  end

  private

  def validate_service_providers
    errors.add(:service_providers, 'must be absent.') if self.service.is_service_provider_required.to_bool.false? && self.service_providers.present?
    errors.add(:service_providers, 'must be present.') if self.service.is_service_provider_required.to_bool.true? && self.service_providers.blank?
  end

  # def validate_units_and_minutes
  #   if self.units.present? && self.minutes.present?
  #     minutes = self.units*15
  #     errors.add(:client_enrollment_service, "The units/minutes are wrong. 1 unit is equivalent to 15 minutes, and vice versa.") if minutes != self.minutes
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

  def validate_count_of_units
    used_and_scheduled_units = self.schedulings&.with_rendered_or_scheduled_as_status&.with_units&.pluck(:units)&.sum
    errors.add(:units, "Units entered in client_enrollment service are less than #{used_and_scheduled_units} units used in schedulings.") if used_and_scheduled_units>0 && self.units < used_and_scheduled_units
  end

  def validate_dates
    client_enrollment_services = ClientEnrollmentService.by_client_enrollment(self.client_enrollment_id)
                                                        .by_service(self.service_id)
                                                        .where.not(id: self.id)
    client_enrollment_services = client_enrollment_services.where('start_date <= ? AND end_date >= ?', self.start_date, self.start_date)
                                                           .or(client_enrollment_services.where('start_date >= ? AND start_date <= ?', self.start_date, self.end_date))
    client_enrollment_services = client_enrollment_services.map{|client_enrollment_service| client_enrollment_service if client_enrollment_service.left_units > 0}
    errors.add(:client_enrollment_service, 'cannot be created for given start date and end date.') if client_enrollment_services.any?
  end
  # end of private
end
