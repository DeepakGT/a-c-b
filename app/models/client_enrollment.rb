class ClientEnrollment < ApplicationRecord
  belongs_to :client
  belongs_to :funding_source, optional: true
  has_many :client_enrollment_services

  enum relationship: { parent_or_guardian: 0, spouse_or_partner: 1 }, _prefix: true
  enum source_of_payment: { self_pay: 0, insurance: 1, single_case_agreement: 2 }

  scope :active, ->{ where('terminated_on > ?',Time.now.to_date).or(where('terminated_on IS NULL')) }
  scope :except, ->(ids) { where.not(id: ids) }
end
