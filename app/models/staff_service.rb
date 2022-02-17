class StaffService < ApplicationRecord
  belongs_to :staff
  belongs_to :service
end
