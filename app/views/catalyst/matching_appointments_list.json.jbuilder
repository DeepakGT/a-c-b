json.partial! 'catalyst_data_detail', catalyst_data: @catalyst_data, schedules: @schedules, action: 'matching_appointments_list'
if @schedules.present?
  json.matching_appointments_found true
  json.message "Best match appointment already present. Do you still wants to add new one ?"
else
  json.matching_appointments_found false
end
