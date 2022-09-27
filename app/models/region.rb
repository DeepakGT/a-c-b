class Region < ApplicationRecord
  has_one :clinic
  validates :name, presence: true, uniqueness: true, length: { minimum: 3, maximum: 50 }
end
