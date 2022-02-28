class Scheduling < ApplicationRecord
  belongs_to :staff
  belongs_to :client
  belongs_to :service
  has_many :soap_notes, dependent: :destroy

  validate :validate_time

  private

  def validate_time
    same_day_schedules = Scheduling.where(staff_id: self.staff_id, client_id: self.client_id, service_id: self.service_id, date: self.date)
    return if same_day_schedules.blank?
    
    overlapping_time_schedules = same_day_schedules.where("start_time <= ? AND end_time >= ?", self.start_time, self.end_time)
                                                   .or(same_day_schedules.where("start_time > ? AND end_time < ?", self.start_time, self.end_time))
                                                   .or(same_day_schedules.where("start_time < ? AND end_time > ?", self.start_time, self.start_time))
                                                   .or(same_day_schedules.where("start_time < ? AND end_time > ?", self.end_time, self.end_time))
    return if overlapping_time_schedules.blank?
    
    errors.add(:scheduling, 'must not have overlapping time for same staff, client and service on same date')
  end
  # end of private
end
