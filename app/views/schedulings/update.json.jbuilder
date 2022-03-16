json.status @schedule.errors.any? ? 'failure' : 'success'
json.data do
  client = @schedule.client_enrollment_service&.client_enrollment&.client
  service = @schedule.client_enrollment_service&.service
  json.id @schedule.id
  json.client_enrollment_service_id @schedule.client_enrollment_service_id
  json.client_id client&.id
  json.client_name "#{client.first_name} #{client.last_name}" if client.present?
  json.staff_id @schedule.staff_id
  json.staff_name "#{@schedule.staff.first_name} #{@schedule.staff.last_name}" if @schedule.staff.present?
  json.service_id service&.id
  json.service_name service&.name
  json.service_display_code service&.display_code 
  json.status @schedule.status
  json.date @schedule.date
  json.start_time @schedule.start_time
  json.end_time @schedule.end_time
  json.units @schedule.units
  json.minutes @schedule.minutes
end
json.errors @schedule.errors.full_messages
