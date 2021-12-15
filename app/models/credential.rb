class Credential < ApplicationRecord
  # has_many :qualifications_credentials, dependent: :destroy
  # has_many :qualifications, through: :qualifications_credentials

  enum credential_type: {education: 0, certification: 1, other: 2}
end
