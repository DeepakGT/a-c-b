class StaffClinic < ApplicationRecord
  belongs_to :staff
  belongs_to :clinic

  validates_uniqueness_of :clinic_id, scope: :staff_id
  validates_uniqueness_of :staff_id, scope: :is_home_clinic, conditions: ->{where(is_home_clinic: true)},
    message: 'can have only one home clinic.' 
end
