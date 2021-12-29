class Organization < ApplicationRecord
  # associations
  belongs_to :admin, class_name: 'User'

  has_one :address, as: :addressable
  has_many :phone_numbers, as: :phoneable
  has_many :clinics

  accepts_nested_attributes_for :address, update_only: true
  accepts_nested_attributes_for :phone_numbers#, update_only: true

  enum status: {active: 0, inactive: 1}

  validates :name, presence: true
  validates_uniqueness_of :name

  # validations
  validate :admin_must_be_a_aba_admin

  private

  def admin_must_be_a_aba_admin
    errors.add(:admin, 'User must be an aba_admin.') unless admin.aba_admin?
  end

  # end of private

end
