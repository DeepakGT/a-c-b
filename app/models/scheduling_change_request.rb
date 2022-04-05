class SchedulingChangeRequest < ApplicationRecord
  belongs_to :scheduling

  enum approved_status: {approved: 0, declined: 1}

  validate :validate_status

  private

  def validate_status
    if self.status.present? && self.status!='Client_Cancel_Greater_than_24_h' && self.status!='Client_Cancel_Less_than_24_h' && self.status!='Client_No_Show'
      errors.add(:status, 'RBTs cannot request change status to given value.')
    end
  end
end
