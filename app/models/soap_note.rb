class SoapNote < ApplicationRecord
  attr_accessor :caregiver_sign
  attr_accessor :user

  belongs_to :scheduling, optional: true
  has_one_attached :signature_file

  before_save :set_signature_file
  before_save :set_storage
  
  validate :validate_signatures

  scope :by_client, ->(client_id){ joins(scheduling: [{client_enrollment_service: :client_enrollment}]).where('client_enrollments.client_id': client_id) }

  private

  def set_signature_file
    return if self.caregiver_sign.blank?

    decoded_data = Base64.decode64(self.caregiver_sign.split(',')[1])
    self.signature_file = {
      io: StringIO.new(decoded_data),
      filename: 'signature'
    }
  end

  def set_storage
    # need to remove conditions after live
    return if Rails.env.development? || Rails.env.production? || Rails.env.test? 

    return if !self.signature_file.attached?

    # larger that 5mb file would be upload on s3
    if signature_file.blob.byte_size > 5_000_000
      Rails.application.config.active_storage.service = :amazon
    else
      Rails.application.config.active_storage.service = :local
    end
  end

  def validate_signatures
    if self.scheduling.present?
      if scheduling.staff.role_name=='bcba'
        if user.role_name=='rbt' && self.rbt_signature==true && self.rbt_signature_author_name=="#{user.first_name} #{user.last_name}"
          errors.add(:rbt_signature, 'must not be present for appointment created for bcba.')
        end
        if user.role_name=='bcba' && self.bcba_signature==true && self.bcba_signature_author_name=="#{user.first_name} #{user.last_name}"
          if !(self.scheduling.client_enrollment_service.staff.include?(user)) && scheduling.staff_id!=user.id && scheduling.client_enrollment_service.client_enrollment.client.bcba_id!=user.id
            errors.add(:bcba_signature, 'cannot be done by bcba that is not in authorization.')
          end
        end
      elsif scheduling.staff.role_name=='rbt'
        if user.role_name=='rbt' && self.rbt_signature==true && self.rbt_signature_author_name=="#{user.first_name} #{user.last_name}"
          errors.add(:rbt_signature, 'cannot be done by rbt that is not in appointment. Please update appointment to let another rbt sign.') if self.scheduling.staff!=user
        elsif user.role_name=='bcba' && self.rbt_signature==true && self.rbt_signature_author_name=="#{user.first_name} #{user.last_name}"
          errors.add(:rbt_signature, 'cannot be done by bcba.')
        end
      end
    end
    if self.bcba_signature==true && self.bcba_signature_author_name=="#{user.first_name} #{user.last_name}" && !(user.role.permissions.include?('bcba_signature')) && user.role_name!='bcba'
      errors.add(:bcba_signature, 'You are not authorized to sign as a bcba.')
    end
    if self.rbt_signature==true && self.rbt_signature_author_name=="#{user.first_name} #{user.last_name}" && !(user.role.permissions.include?('rbt_signature')) && user.role_name!='rbt'
      errors.add(:rbt_signature, 'You are not authorized to sign as a rbt.')
    end
    if self.clinical_director_signature==true && self.clinical_director_signature_author_name=="#{user.first_name} #{user.last_name}" && !(user.role.permissions.include?('clinical_director_signature')) && user.role_name!='clinical_director'
      errors.add(:clinical_director_signature, 'You are not authorized to sign as a clinical director.')
    end
  end
  # end of private
end
