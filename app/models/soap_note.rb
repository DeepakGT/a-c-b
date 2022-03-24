class SoapNote < ApplicationRecord
  attr_accessor :caregiver_signature

  belongs_to :scheduling
  has_one_attached :signature_file

  before_save :set_signature_file
  before_save :set_storage

  scope :by_client, ->(client_id){ joins(scheduling: [{client_enrollment_service: :client_enrollment}]).where('client_enrollments.client_id': client_id) }

  private

  def set_signature_file
    return if self.caregiver_signature.blank?

    decoded_data = Base64.decode64(self.caregiver_signature.split(',')[1])
    self.signature_file = {
      io: StringIO.new(decoded_data),
      filename: 'signature'
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
