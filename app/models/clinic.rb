class Clinic < ApplicationRecord
  has_one :address, as: :addressable, dependent: :destroy, inverse_of: :addressable
  has_one :phone_number, as: :phoneable, dependent: :destroy, inverse_of: :phoneable
  has_many :staff_clinics, dependent: :destroy
  has_many :staff, through: :staff_clinics
  has_many :clients, dependent: :destroy
  has_many :funding_sources, dependent: :destroy
  belongs_to :region, optional: true


  belongs_to :organization

  accepts_nested_attributes_for :address, update_only: true
  accepts_nested_attributes_for :phone_number, update_only: true

  enum status: {active: 0, inactive: 1}

  delegate :name, to: :organization, prefix: true
  delegate :name, to: :region, prefix: true

  scope :by_org_id, ->(org_id){ where('organization_id': org_id) }

  # validates :name, presence: true
  # validates_uniqueness_of :name, scope: :organization_id
end
