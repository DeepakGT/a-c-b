class ClientEnrollment < ApplicationRecord
  belongs_to :client
  belongs_to :funding_source
end
