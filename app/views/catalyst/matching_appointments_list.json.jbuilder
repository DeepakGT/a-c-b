json.status 'success'
json.data do
  json.partial! 'catalyst_data_detail', catalyst_data: @catalyst_data
  json.appointments do
    json.array! @schedules do |schedule|
      json.partial! 'schedulings/scheduling_detail', schedule: schedule
      json.staff_role schedule.staff.role_name if schedule.staff.present?
      json.is_early_code service&.is_early_code
      soap_note = schedule.soap_notes&.order(add_date: :desc, add_time: :desc).first
      if soap_note.present?
        json.soap_note do
          json.partial! 'soap_notes/soap_note_detail', soap_note: soap_note
        end
      end
    end
  end
end
if @schedules.present?
  json.matching_appointments_found true
  json.message "Best match appointment already present. Do you still wants to add new one ?"
else
  json.matching_appointments_found false
end
