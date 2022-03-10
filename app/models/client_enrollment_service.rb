class ClientEnrollmentService < ApplicationRecord
  belongs_to :client_enrollment
  belongs_to :service

  has_many :service_providers, class_name: :ClientEnrollmentServiceProvider, dependent: :destroy
  has_many :staff, through: :service_providers

  accepts_nested_attributes_for :service_providers

  validate :valdate_service_providers

  private

  def valdate_service_providers
    return if service.is_service_provider_required.false?

    errors.add(:service_providers, 'must be present.') if self.service_providers.blank?
  end
end
