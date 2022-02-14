class Attachment < ApplicationRecord
  belongs_to :attachable, polymorphic: true

  has_one_attached :file

  # order is important here
  after_initialize :set_storage

  private

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
