class SoapNote < ApplicationRecord
  attr_accessor :caregiver_signature
  attr_accessor :user

  belongs_to :scheduling
  has_one_attached :signature_file

  before_save :set_signature_file
  before_save :set_storage
  
  validate :validate_signatures

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

  def validate_signatures
    if scheduling.staff.role_name=='bcba'
      if user.role_name=='rbt' && self.rbt_signature==true && self.rbt_signature_author_name=="#{user.first_name} #{user.last_name}"
        errors.add(:rbt_signature, 'must not be present for appointment created for bcba.')
      end
      if user.role_name=='bcba' && self.bcba_signature==true && self.bcba_signature_author_name=="#{user.first_name} #{user.last_name}"
        errors.add(:bcba_signature, 'cannot be done by bcba that is not in authorization.') if !(self.scheduling.client_enrollment_service.staff.include?(user))
      end
    elsif scheduling.staff.role_name=='rbt'
      if user.role_name=='rbt' && self.rbt_signature==true && self.rbt_signature_author_name=="#{user.first_name} #{user.last_name}"
        errors.add(:rbt_signature, 'cannot be done by rbt that is not in appointment. Please update appointment to let another rbt sign.') if self.scheduling.staff!=user
      end
    end
    if user.role_name!='super_admin' && user.role_name!='aba_admin'
      if self.rbt_signature==false || self.bcba_signature==false || self.clinical_director_signature==false
        errors.add(:signatures, 'You are not authorized to undo the signatures.')
      end
    end
  end
  # end of private
end
