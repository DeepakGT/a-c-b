class UserClinic < ApplicationRecord
  belongs_to :staff
  belongs_to :clinic
end
