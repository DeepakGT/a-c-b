class Credential < ApplicationRecord
  has_many :qualifications_credentials, dependent: :destroy
  has_many :qualifications, through: :qualifications_credentials

  enum type: {education: 0, certification: 1, other: 2}, prefix: true
end
