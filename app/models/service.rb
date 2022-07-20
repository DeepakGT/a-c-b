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

  private

  def validate_is_early_code
    if params[:is_early_code].to_bool.true?
      billable_funding_sources = ClientEnrollmentService.by_service(self.id).joins(client_enrollment: :funding_source).where.not('funding_sources.network_status = ?', 'non_billable')
      errors.add(:is_early_code, 'cannot be updated to true if service has billable payors in the auth.') if billable_funding_sources.present?
    end
  end
end
