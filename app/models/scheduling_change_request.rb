class SchedulingChangeRequest < ApplicationRecord
  belongs_to :scheduling

  enum approval_status: {approved: 0, declined: 1}

  validate :validate_status

  scope :by_approval_status, ->{ where(approval_status: nil) }
  scope :by_bcba_ids, ->(bcba_ids){ left_outer_joins(scheduling: {client_enrollment_service: {client_enrollment: :client}}).where('users.bcba_id': bcba_ids) }
  scope :by_staff_ids, ->(staff_ids){ where('schedulings.staff_id': staff_ids) }
  scope :by_client_ids, ->(client_ids){ joins(scheduling: {client_enrollment_service: :client_enrollment}).where('client_enrollments.client_id': client_ids) }

  private

  def validate_status
    if self.status.present? && self.status!='Client_Cancel_Greater_than_24_h' && self.status!='Client_Cancel_Less_than_24_h' && self.status!='Client_No_Show'
      errors.add(:status, 'RBTs cannot request change status to given value.')
    end
  end
end
