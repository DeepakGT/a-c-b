class Organization < ApplicationRecord
  # associations
  belongs_to :admin, class_name: 'User'

  has_one :address, as: :addressable
  has_one :phone_number, as: :phoneable
  has_many :clinics

  accepts_nested_attributes_for :address, update_only: true
  accepts_nested_attributes_for :phone_number, update_only: true

  enum status: {active: 0, inactive: 1}

  validates :name, presence: true
  validates_uniqueness_of :name
end
