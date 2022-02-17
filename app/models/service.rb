class Service < ApplicationRecord
  # Associations
  has_many :staff_services, dependent: :destroy
  has_many :staff, through: :staff_services
  has_many :client_enrollment_services

  # Enums
  enum status: {active: 0, inactive: 1}
end
