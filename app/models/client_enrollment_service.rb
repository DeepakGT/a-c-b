class ClientEnrollmentService < ApplicationRecord
  belongs_to :client_enrollment
  belongs_to :service

  has_many :service_providers, class_name: :ClientEnrollmentServiceProvider, dependent: :destroy
  has_many :staff, through: :service_providers
  has_many :schedulings, dependent: :destroy

  accepts_nested_attributes_for :service_providers

  validate :validate_service_providers

  scope :by_client, ->(client_id){ joins(:client_enrollment).where('client_enrollments.client_id = ?',client_id) }
  scope :by_date, ->(date){ where('start_date <= ? AND end_date >= ?', date, date) }
  scope :by_staff, ->(staff_id){ joins(:service_providers).where('client_enrollment_service_providers.staff_id': staff_id) }
  scope :by_service, ->(service_ids){ where(service_id: service_ids) }
  scope :by_staff_qualifications, ->(staff_qualification_ids) { where('service_qualifications.qualification_id': staff_qualification_ids) }
  scope :by_service_with_no_qualification, ->{select("client_enrollment_services.*").group("client_enrollment_services.id").having("count(service_qualifications.*) = ?",0)}

  private

  def validate_service_providers
    errors.add(:service_providers, 'must be absent.') if service.is_service_provider_required.false? && self.service_providers.present?
    errors.add(:service_providers, 'must be present.') if service.is_service_provider_required.true? && self.service_providers.blank?
  end
end
