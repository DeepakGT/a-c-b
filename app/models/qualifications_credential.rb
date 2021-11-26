class QualificationsCredential < ApplicationRecord
  belongs_to :qualification, inverse_of: :qualifications_credentials
  belongs_to :credential, inverse_of: :qualifications_credentials

  before_create :assign_issued_at

  validate :validate_expires_at

  private
  def assign_issued_at
    self.issued_at = Date.today
  end

  def validate_expires_at
    if credential.lifetime? && self.expires_at.present?
      errors.add(:expires_at, 'must be blank for lifetime credential.')
    end
  end
  # end of private
end
