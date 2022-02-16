class ClientEnrollment < ApplicationRecord
  belongs_to :client
  belongs_to :funding_source, optional: true

  enum relationship: { parent_or_guardian: 0, spouse_or_partner: 1 }
  enum source_of_payment: { self_pay: 0, insurance: 1, single_case_agreement: 2 }
end
