class SchedulingChangeRequest < ApplicationRecord
  belongs_to :scheduling

  enum approval_status: {approved: 0, declined: 1}

  validate :validate_status
  validate :validate_change_request, on: :create

  scope :by_approval_status, ->{ where(approval_status: nil) }
  scope :by_bcba_ids, ->(bcba_ids){ left_outer_joins(scheduling: {client_enrollment_service: {client_enrollment: :client}}).where('clients.bcba_id': bcba_ids) }
  scope :by_staff_ids, ->(staff_ids){ where('schedulings.staff_id': staff_ids) }
  scope :by_client_ids, ->(client_ids){ joins(scheduling: {client_enrollment_service: :client_enrollment}).where('client_enrollments.client_id': client_ids) }

  private

  def validate_status
    errors.add(:status, 'RBTs cannot request change status to given value.') if self.status.present? && self.status!='Client_Cancel_Greater_than_24_h' && self.status!='Client_Cancel_Less_than_24_h' && self.status!='Client_No_Show'
    errors.add(:status, 'No further change requests for given schedule can be created.') if self.scheduling.status=='Client_No_Show' && self.status!='Client_No_Show'
  end

  def validate_change_request
    schedule = Scheduling.find(self.scheduling_id)
    errors.add(:approval_status, 'No further change requests for given schedule can be created unless old change requests are approved or declined.') if schedule.scheduling_change_requests.by_approval_status.any? && self.status!='Client_No_Show'
  end
end
