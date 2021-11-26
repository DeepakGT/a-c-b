class FundingSource < ApplicationRecord
  has_many :qualifications_credentials_funding_sources, dependent: :destroy
  has_many :qualifications_credentials, through: :qualifications_credentials_funding_sources, dependent: :destroy
  has_many :qualifications, through: :qualifications_credentials
end
