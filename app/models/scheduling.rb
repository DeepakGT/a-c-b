class Scheduling < ApplicationRecord
  belongs_to :staff
  belongs_to :client
  belongs_to :service
  has_many :soap_notes, dependent: :destroy

  validates_presence_of :date, :start_time, :end_time, :status
  validates_presence_of :units, message: "or minutes, any one must be present.", if: proc { |obj| obj.minutes.blank? }
  validates_absence_of :units, message: "or minutes, only one must be present.", if: proc { |obj| obj.minutes.present? }

  validate :validate_time

  private

  def validate_time
    possible_schedules = Scheduling.where.not(id: self.id)
    same_day_schedules = possible_schedules.where(staff_id: self.staff_id, client_id: self.client_id, service_id: self.service_id, date: self.date)
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
