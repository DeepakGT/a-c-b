class StaffQualification < ApplicationRecord
  belongs_to :staff, class_name: 'User'
  belongs_to :qualification, foreign_key: :credential_id

  validates :credential_id, uniqueness: { scope: :staff_id }
  validate :validate_expires_at

  scope :by_user, ->(user) { where(staff_id: user.id).first }

  private

  def validate_expires_at
    errors.add(:expires_at, 'must be blank for lifetime qualification.') if self.qualification.lifetime? && self.expires_at.present?
  end

  # end of private
end
