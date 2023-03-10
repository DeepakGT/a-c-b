class FundingSource < ApplicationRecord
  has_one :phone_number, as: :phoneable, dependent: :destroy, inverse_of: :phoneable
  has_one :address, as: :addressable, dependent: :destroy, inverse_of: :addressable
  has_many :client_enrollments, dependent: :nullify
  has_many :clients, through: :client_enrollments
  belongs_to :clinic

  enum status: {active: 0, inactive: 1}
  enum network_status: {in_network: 0, out_of_network: 1, self_pay: 2, insurance: 3, non_billable: 4}
  enum payor_type: { commercial: 0, medicaid: 1, medicare: 2, third_party_contract: 3 }

  accepts_nested_attributes_for :phone_number, update_only: true
  accepts_nested_attributes_for :address, update_only: true

  scope :non_billable_funding_sources, ->{where(network_status: 'non_billable')}
  scope :billable_funding_sources, ->{where.not(network_status: 'non_billable')}

  validate :validate_non_billable_payors, on: :update

  private

  def validate_non_billable_payors
    if self.non_billable?
      services = FundingSource.joins(client_enrollments: {client_enrollment_services: :service}).where('funding_sources.id': self.id).where('services.is_early_code': false)
      errors.add(:funding_source, 'cannot be made non-billable as it has authorization with service that is not an early code.') if services.present?
    end
  end

  def self.transform_payor_types
    payor_types.map do |type, _|
      {'value' => type , 'title'=> I18n.t("activerecord.attributes.funding_source.payor_types.#{type}").capitalize }
    end
  end
  
end
