class Scheduling < ApplicationRecord
  belongs_to :staff
  belongs_to :client
  belongs_to :service
end
