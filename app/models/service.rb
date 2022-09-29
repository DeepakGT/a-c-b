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
  validate :validate_selected_payors

  # Enums
  enum status: {active: 0, inactive: 1}

  scope :non_early_services, ->{where(is_early_code: false)}
  scope :early_services, ->{where(is_early_code: true)}
  
  def is_early_code?
    self&.is_early_code&.to_bool&.true?
  end

  def is_not_early_code?
    self&.is_early_code&.to_bool&.false?
  end

  private

  def validate_is_early_code
    if self&.is_early_code? && Service.find(self.id)&.is_not_early_code?
      billable_funding_sources = ClientEnrollmentService.by_service(self.id).joins(client_enrollment: :funding_source).where.not('funding_sources.network_status': 'non_billable')
      errors.add(:service, I18n.t('activerecord.attributes.service.validate_is_early_code')) if billable_funding_sources.present?
    end
  end

  def validate_selected_payors
    errors.add(:early_service, I18n.t('activerecord.attributes.service.validate_selected_payors')) if self&.is_early_code? && (self&.selected_payors.blank? || JSON.parse(self&.selected_payors).count==0) 
  end
end
