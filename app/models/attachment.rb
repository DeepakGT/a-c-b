class Attachment < ApplicationRecord
  attr_accessor :base64

  belongs_to :attachable, polymorphic: true

  has_one_attached :file

  after_initialize :set_file

  enum category: {
    lmn: 'lmn',
    dx: 'dx',
    dx_video: 'dx_video'
  }, _prefix: true

  def set_file
    return if self.base64.blank?
    decoded_data = Base64.decode64(self.base64.split(',')[1])
    self.file = { 
      io: StringIO.new(decoded_data),
      content_type: 'image/jpeg',
      filename: 'image.jpg'
    }
  end

end
