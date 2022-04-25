class CatalystData < ApplicationRecord
  scope :with_no_appointments, ->{ where(is_appointment_found: false) }
  scope :with_multiple_appointments, ->{ where.not(multiple_schedulings_ids: []) }
end
