class Organization < ApplicationRecord
  has_one :address, as: :addressable
  has_many :clinics
end
