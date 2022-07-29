class Service < ApplicationRecord
  # Associations
  has_many :service_qualifications, dependent: :destroy
  has_many :qualifications, through: :service_qualifications
  has_many :client_enrollment_services, dependent: :destroy
  has_many :staff_clinic_services, dependent: :destroy
  has_many :staff_clinics, through: :staff_clinic_services

  accepts_nested_attributes_for :service_qualifications

  validates :display_code, format: { with: /\A[a-zA-Z0-9]+\z/, message: "only allows alphanumeric characters." }
  validate :validate_is_early_code, on: :update

  # Enums
  enum status: {active: 0, inactive: 1}

  serialize :selected_payors, Array

  scope :non_early_services, ->{where(is_early_code: false)}
  private

  def validate_is_early_code
    if self.is_early_code.to_bool.true? && Service.find(self.id).is_early_code.to_bool.false?
      billable_funding_sources = ClientEnrollmentService.by_service(self.id).joins(client_enrollment: :funding_source).where.not('funding_sources.network_status': 'non_billable')
      errors.add(:service, 'cannot be updated to early code as it is connected to billable payors.') if billable_funding_sources.present?
    end
  end
end
