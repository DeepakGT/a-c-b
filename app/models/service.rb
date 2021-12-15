class Service < ApplicationRecord
  # Associations
  has_many :user_services, dependent: :destroy
  has_many :users, through: :user_services

  # Enums
  enum status: {active: 0, inactive: 1}
end
