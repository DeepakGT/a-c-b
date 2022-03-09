class Service < ApplicationRecord
  # Associations
  has_many :service_qualifications, dependent: :destroy
  has_many :qualifications, through: :service_qualifications
  has_many :client_enrollment_services
  has_one :scheduling

  accepts_nested_attributes_for :service_qualifications

  validates :display_code, format: { with: /\A[a-zA-Z0-9]+\z/, message: "only allows alphanumeric characters." }

  # Enums
  enum status: {active: 0, inactive: 1}
end
