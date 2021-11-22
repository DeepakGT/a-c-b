class Organization < ApplicationRecord
  # associations
  belongs_to :admin, class_name: 'User'

  has_one :address, as: :addressable
  has_many :clinics

  validates :name, presence: true
  validates_uniqueness_of :name

  # validations
  validate :admin_must_be_a_aba_admin

  private

  def admin_must_be_a_aba_admin
    unless admin.aba_admin?
      errors.add(:admin, 'User must be an aba_admin.')
    end
  end

  # end of private

end
