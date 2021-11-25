class Qualification < ApplicationRecord
  belongs_to :staff

  has_many :qualifications_credentials, dependent: :destroy
  has_many :credentials, through: :qualifications_credentials

  has_many :qualifications_funding_sources, dependent: :destroy
  has_many :funding_sources, through: :qualifications_funding_sources
end
