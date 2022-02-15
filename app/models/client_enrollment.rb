class ClientEnrollment < ApplicationRecord
  belongs_to :client
  belongs_to :funding_source

  validates_uniqueness_of :client_id, scope: :is_primary, conditions: -> { where(is_primary: 'true') },
    message: 'can have only one primary funding source.'

  enum relationship: { parent_or_guardian: 0, spouse_or_partner: 1 }
  enum source_of_payment: { self_pay: 0, insurance: 1, contract: 2, medicaid: 3, 
                            single_case_agreement: 4, scholarship: 5 }
end
