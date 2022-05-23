class StaffClinic < ApplicationRecord
  belongs_to :staff
  belongs_to :clinic

  has_many :staff_clinic_services, dependent: :destroy
  has_many :services, through: :staff_clinic_services

  accepts_nested_attributes_for :staff_clinic_services

  validates_uniqueness_of :clinic_id, scope: :staff_id
  # validates_uniqueness_of :staff_id, scope: :is_home_clinic, conditions: ->{where(is_home_clinic: true)},
  #   message: 'can have only one home clinic.' 

  scope :except_ids, ->(ids){ where.not(id: ids) }
end
