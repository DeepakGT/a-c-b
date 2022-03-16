json.status 'success'
json.data do
  client = @schedule.client_enrollment_service&.client_enrollment&.client
  service = @schedule.client_enrollment_service&.service
  schedules = Scheduling.by_client_and_service(@schedule.client_enrollment_service.client_enrollment.client_id, @schedule.client_enrollment_service.service_id)
  schedules = schedules.by_status
  completed_schedules = schedules.completed_scheduling
  scheduled_schedules = schedules.scheduled_scheduling
  used_units = completed_schedules.with_units.pluck(:units).sum
  scheduled_units = scheduled_schedules.with_units.pluck(:units).sum
  used_minutes = completed_schedules.with_minutes.pluck(:minutes).sum
  scheduled_minutes = scheduled_schedules.with_minutes.pluck(:minutes).sum
  json.id @schedule.id
  json.client_enrollment_service_id @schedule.client_enrollment_service_id
  json.total_units @schedule.client_enrollment_service.units
  json.used_units used_units
  json.scheduled_units scheduled_units
  if @schedule.client_enrollment_service.units.present?
    json.left_units @schedule.client_enrollment_service.units - (used_units + scheduled_units) 
  else
    json.left_units 0
  end
  json.total_minutes @schedule.client_enrollment_service.minutes
  json.used_minutes used_minutes
  json.scheduled_minutes scheduled_minutes
  if @schedule.client_enrollment_service.minutes.present?
    json.left_minutes @schedule.client_enrollment_service.minutes - (used_minutes + scheduled_minutes)
  else
    json.left_minutes 0
  end
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
