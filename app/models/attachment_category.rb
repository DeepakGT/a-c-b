class AttachmentCategory < ApplicationRecord
  has_many :attachments
  before_validation :transform_name
  validates :name, presence: true, uniqueness: true

  private

  def transform_name
    if name.present?
      self.name = name.downcase unless name.blank?
    end
  end
end
