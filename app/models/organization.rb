class Organization < ApplicationRecord
  has_one :address, as: :addressable
  has_many :clinics

  validates :name, presence: true
  validates_uniqueness_of :name
end
