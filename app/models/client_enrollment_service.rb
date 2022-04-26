class ClientEnrollmentService < ApplicationRecord
  belongs_to :client_enrollment
  belongs_to :service

  has_many :service_providers, class_name: :ClientEnrollmentServiceProvider, dependent: :destroy
  has_many :staff, through: :service_providers
  has_many :schedulings, dependent: :destroy

  accepts_nested_attributes_for :service_providers

  validate :validate_service_providers
  validate :validate_units_and_minutes

  before_save :set_units_and_minutes

  scope :by_client, ->(client_ids){ joins(:client_enrollment).where('client_enrollments.client_id': client_ids) }
  scope :by_date, ->(date){ where('start_date <= ? AND end_date >= ?', date, date) }
  scope :by_staff, ->(staff_id){ joins(:service_providers).where('client_enrollment_service_providers.staff_id': staff_id) }
  scope :by_service, ->(service_ids){ where(service_id: service_ids) }
  scope :by_staff_qualifications, ->(staff_qualification_ids) { where('service_qualifications.qualification_id': staff_qualification_ids) }
  scope :by_service_with_no_qualification, ->{select("client_enrollment_services.*").group("client_enrollment_services.id").having("count(service_qualifications.*) = ?",0)}
  scope :by_bcba_ids, ->(bcba_ids){ joins(client_enrollment: :client).where('clients.bcba_id': bcba_ids) }
  scope :about_to_expire, ->{ where('end_date>=? AND end_date<=?', Time.now.to_date, (Time.now.to_date+9)) }

  private

  def validate_service_providers
    errors.add(:service_providers, 'must be absent.') if service.is_service_provider_required.to_bool.false? && self.service_providers.present?
    errors.add(:service_providers, 'must be present.') if service.is_service_provider_required.to_bool.true? && self.service_providers.blank?
  end

  def validate_units_and_minutes
    if self.units.present? && self.minutes.present?
      minutes = self.units*15
      errors.add(:client_enrollment_service, "The units/minutes are wrong. 1 unit is equivalent to 15 minutes, and vice versa.") if minutes != self.minutes
    end
  end

  def set_units_and_minutes
    if self.units.present? && self.minutes.blank?
      self.minutes = self.units*15
    elsif self.minutes.present? && self.units.blank?
      self.units = self.minutes/15
    end
  end
end
