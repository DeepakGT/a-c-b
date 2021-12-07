class Service < ApplicationRecord
  # Associations
  has_many :user_services, dependent: :destroy
  has_many :users, through: :user_services

  # Enums
  enum status: {active: 0, inactive: 1}
  enum default_pay_code: {drive_time: 0, hourly: 1, paid_time_off: 2}
  enum category: { aba: 0,
                   activities_arts_sports: 1,
                   adult_services: 2,
                   non_service: 3,
                   ot: 4,
                   psych: 5,
                   pt: 6,
                   respite_supported_living: 7,
                   slp: 8,
                   social_skills: 9,
                   tutoring: 10,
                   virtual: 11,
                   other: 12 }
  enum tracking_id: { nan_rbt: 0 }
end
