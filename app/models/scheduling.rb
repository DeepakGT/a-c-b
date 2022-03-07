class Scheduling < ApplicationRecord
  belongs_to :staff
  belongs_to :client
  belongs_to :service
  has_many :soap_notes, dependent: :destroy

  validates_presence_of :date, :start_time, :end_time, :status
  validates_presence_of :units, message: "or minutes, any one must be present.", if: proc { |obj| obj.minutes.blank? }
  validates_absence_of :units, message: "or minutes, only one must be present.", if: proc { |obj| obj.minutes.present? }

  validate :validate_time

  #scopes
  scope :by_status, ->{ where('lower(status) = ?','scheduled') }
  scope :completed_scheduling, ->{ where('date < ?',Time.now.to_date) }
  scope :scheduled_scheduling, ->{ where('date >= ?',Time.now.to_date) }
  scope :with_units, ->{ where.not(units: nil) }
  scope :with_minutes, ->{ where.not(minutes: nil) }
  scope :by_client_and_service, ->(client_id, service_id){ where(client_id: client_id, service_id: service_id)}
  scope :by_first_name, ->(fname){ where('lower(users.first_name) LIKE ?',"%#{fname&.downcase}%") }
  scope :by_last_name, ->(lname){ where('lower(users.last_name) LIKE ?',"%#{lname&.downcase}%") }
  scope :by_service, ->(service_name){ where('lower(services.name) LIKE ?',"%#{service_name&.downcase}%") }

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
