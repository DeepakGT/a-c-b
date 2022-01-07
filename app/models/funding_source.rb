class FundingSource < ApplicationRecord
  # has_many :qualifications_credentials_funding_sources, dependent: :destroy
  # has_many :qualifications_credentials, through: :qualifications_credentials_funding_sources, dependent: :destroy
  # has_many :qualifications, through: :qualifications_credentials

  has_one :phone_number, as: :phoneable, dependent: :destroy
  has_one :address, as: :addressable, dependent: :destroy
  belongs_to :clinic

  enum network_status: {in_network: 0, out_of_network: 1}
  enum payer_type: { commercial: 0, medicaid: 1, medicare: 2}

  accepts_nested_attributes_for :phone_number, update_only: true
  accepts_nested_attributes_for :address, update_only: true
end
