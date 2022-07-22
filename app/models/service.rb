class Service < ApplicationRecord
  # Associations
  has_many :service_qualifications, dependent: :destroy
  has_many :qualifications, through: :service_qualifications
  has_many :client_enrollment_services, dependent: :destroy
  has_many :staff_clinic_services, dependent: :destroy
  has_many :staff_clinics, through: :staff_clinic_services

  accepts_nested_attributes_for :service_qualifications

  validates :display_code, format: { with: /\A[a-zA-Z0-9]+\z/, message: "only allows alphanumeric characters." }

  # Enums
  enum status: {active: 0, inactive: 1}

  serialize :selected_non_early_services, Array
  serialize :selected_non_billable_payors, Array
  serialize :payors_requiring_rendering_provider, Array

  scope :non_early_services, ->{where(is_early_code: false)}
end
