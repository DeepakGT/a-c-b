class ServiceAddressType < ApplicationRecord
  has_many :addresses
  
  validates :tag_num, presence: true, uniqueness: true
  validates :name, presence: true, length: { maximum: 50 }
end
