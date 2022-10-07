class AttachmentCategory < ApplicationRecord
  has_many :attachments
  before_validation :transform_name
  validates :name, presence: true, uniqueness: true, length: { minimum: 2, maximum: 50 },
            format: { with: /\A[a-zA-Z0-9_ ']+\z/, message: 'allows only alphanumeric characters, apostrophe, dashes, and blank spaces' }

  private

  def transform_name
    if name.present?
      self.name = name.downcase unless name.blank?
    end
  end
end
