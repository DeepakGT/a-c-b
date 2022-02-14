class ClientEnrollmentPayment < ApplicationRecord
  belongs_to :client
  belongs_to :funding_source, optional: true

  enum source_of_payment: { self_pay: 0, insurance: 1, contract: 2, medicaid: 3, sca: 4, scholarship: 5 }
  enum relationship: { parent_or_guardian: 0, spouse_or_partner: 1 }
end
