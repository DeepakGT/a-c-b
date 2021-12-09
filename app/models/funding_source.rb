class FundingSource < ApplicationRecord
  # has_many :qualifications_credentials_funding_sources, dependent: :destroy
  # has_many :qualifications_credentials, through: :qualifications_credentials_funding_sources, dependent: :destroy
  # has_many :qualifications, through: :qualifications_credentials

  has_many :phone_numbers, as: :phoneable, dependent: :destroy
  belongs_to :clinic

  enum status: {active: 0, inactive: 1}
end
