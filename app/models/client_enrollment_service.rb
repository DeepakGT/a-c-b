class ClientEnrollmentService < ApplicationRecord
  belongs_to :client_enrollment
  belongs_to :service

  has_many :service_providers, class_name: :ClientEnrollmentServiceProvider, dependent: :destroy
  has_many :staff, through: :service_providers

  accepts_nested_attributes_for :service_providers

  validate :validate_service_providers

  scope :by_client, ->(client_id){ joins(:client_enrollment).where('client_enrollments.client_id = ?',client_id) }
  scope :by_date, ->(date){ where('start_date <= ? AND end_date >= ?', date, date) }
  scope :by_staff, ->(staff_id){ joins(:service_providers).where('client_enrollment_service_providers.staff_id': staff_id) }

  private

  def validate_service_providers
    return if service.is_service_provider_required.false?

    errors.add(:service_providers, 'must be present.') if self.service_providers.blank?
  end
end
