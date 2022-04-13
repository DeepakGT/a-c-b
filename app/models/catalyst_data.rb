class CatalystData < ApplicationRecord
  scope :with_no_appointments, ->{ where(is_appointment_found: false) }
end
