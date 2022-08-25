class AttachmentCategory < ApplicationRecord
  has_many :attachments
  before_validation :transform_name
  validates :name, presence: true, uniqueness: true

  private

  def transform_name
    self.name = self.name.downcase
  end
end
