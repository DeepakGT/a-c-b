class AttachmentCategory < ApplicationRecord
  has_many :attachments

  validates :name, presence: true, uniqueness: true

  scope :all_active_categories, ->{ where(delete_status: false).order(name: :asc) }
end
