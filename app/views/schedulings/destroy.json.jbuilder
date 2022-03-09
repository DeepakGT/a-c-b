json.status 'success'
json.data do
  json.id @schedule.id
  json.client_id @schedule.client_id
  json.client_name "#{@schedule.client.first_name} #{@schedule.client.last_name}" if @schedule.client.present?
  json.staff_id @schedule.staff_id
  json.staff_name "#{@schedule.staff.first_name} #{@schedule.staff.last_name}" if @schedule.staff.present?
  json.service_id @schedule.service_id
  json.service_name @schedule.service.name if @schedule.service.present?
  json.status @schedule.status
  json.date @schedule.date
  json.start_time @schedule.start_time
  json.end_time @schedule.end_time
  json.units @schedule.units
  json.minutes @schedule.minutes
end
