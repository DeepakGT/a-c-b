class Clinic < ApplicationRecord
  has_one :address, as: :addressable
  has_many :staff, class_name: :User
  has_many :funding_sources

  belongs_to :organization

  # validates :name, presence: true
  # validates_uniqueness_of :name, scope: :organization_id
end
