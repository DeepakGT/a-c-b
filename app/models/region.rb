class Region < ApplicationRecord
  has_one :clinic
  validates :name, presence: true, uniqueness: true
end
