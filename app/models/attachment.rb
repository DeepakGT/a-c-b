class Attachment < ApplicationRecord
  attr_accessor :base64
  
  belongs_to :attachable, polymorphic: true
  belongs_to :attachment_category, optional: true

  has_one_attached :file

  validates_presence_of :file_name
  # order is important here
  before_save :set_file
  before_save :set_storage

  scope :by_client_id, ->(client_id){ where(attachable_type: 'Client', attachable_id: client_id) }

  def can_be_displayed?(role)
    return false if self.role_permissions.present? && !self.role_permissions.include?(role) && role != 'super_admin' && role != 'administrator'

    true
  end

  private

  def set_file
    return if self.base64.blank?

    decoded_data = Base64.decode64(self.base64.split(',')[1])
    self.file = {
      io: StringIO.new(decoded_data),
      filename: file_name
    }
  end

  def set_storage
    # need to remove conditions after live
    return if Rails.env.development? || Rails.env.production? || Rails.env.test? 

    # larger that 5mb file would be upload on s3
    if file.blob.byte_size > 5_000_000
      Rails.application.config.active_storage.service = :amazon
    else
      Rails.application.config.active_storage.service = :local
    end
  end
  # end of private
end
