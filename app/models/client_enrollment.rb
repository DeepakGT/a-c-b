class ClientEnrollment < ApplicationRecord
  belongs_to :client
  belongs_to :funding_source

  validates_uniqueness_of :client_id, conditions: -> { where.not(primary: 'false') }, message: 'can have only one primary funding source.'
end
