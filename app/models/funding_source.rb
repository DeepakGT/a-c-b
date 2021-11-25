class FundingSource < ApplicationRecord
  has_many :qualifications_funding_sources, dependent: :destroy
  has_many :qualifications, through: :qualifications_funding_sources
end
