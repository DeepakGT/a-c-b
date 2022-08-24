class AttachmentCategory < ApplicationRecord
  has_many :attachments

  validates :name, presence: true, uniqueness: true
end
