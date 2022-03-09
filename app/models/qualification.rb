class Qualification < ApplicationRecord
  has_many :staff_qualifications, dependent: :destroy, foreign_key: :credential_id
  has_many :staff, through: :staff_qualifications
  has_many :service_qualifications, dependent: :destroy
  has_many :services, through: :service_qualifications

  enum credential_type: {education: 0, certification: 1, other: 2}
end
