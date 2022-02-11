class ClientEnrollment < ApplicationRecord
  belongs_to :client
  belongs_to :funding_source

  validates_uniqueness_of :client_id, scope: :is_primary, conditions: -> { where(is_primary: 'true') },
    message: 'can have only one primary funding source.'
end
