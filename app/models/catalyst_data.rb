require 'audited.rb'
class CatalystData < ApplicationRecord
  audited only: %i[is_deleted_from_connect], on: :update

  scope :with_no_appointments, ->{ where(system_scheduling_id: nil) }
  # scope :with_multiple_appointments, ->{ where.not(multiple_schedulings_ids: []) }
  scope :past_60_days_catalyst_data, ->{ where('date>=? AND date<?', (Time.current-60.days).strftime('%Y-%m-%d'), Time.current.strftime('%Y-%m-%d')) }
  scope :after_live_date, ->{where('date >= ?', Date.strptime("05-20-2022", "%m-%d-%Y").to_date)}
  scope :by_catalyst_user_id, ->(user_id){ where(catalyst_user_id: User.find(user_id).catalyst_user_id) }
  scope :by_catalyst_patient_ids, ->(catalyst_patient_ids){ where(catalyst_patient_id: catalyst_patient_ids) }
  scope :by_active_clients, ->{ where('clients.status = ?', 0) }
  scope :post_30_may_catalyst_data, ->{ where('date>? and date <?', '2022-05-30', Time.current.strftime('%Y-%m-%d')) }
end
