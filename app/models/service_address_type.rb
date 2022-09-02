class ServiceAddressType < ApplicationRecord
  has_many :addresses

  validates :tag_num, presence: true, uniqueness: true
  validates :name, presence: true
end
