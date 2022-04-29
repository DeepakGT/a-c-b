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
  json.cross_site_allowed @schedule.cross_site_allowed
  json.client_id client&.id
  json.client_name "#{client.first_name} #{client.last_name}" if client.present?
  json.service_address_id @schedule.service_address_id
  if @schedule.service_address_id.present?
    service_address = Address.find(@schedule.service_address_id)
    json.service_address do
      json.line1 service_address.line1
      json.line2 service_address.line2
      json.line3 service_address.line3
      json.zipcode service_address.zipcode
      json.city service_address.city
      json.state service_address.state
      json.country service_address.country
      json.is_default service_address.is_default
      json.address_name service_address.address_name
    end
  end
  json.staff_id @schedule.staff_id
  json.staff_name "#{@schedule.staff.first_name} #{@schedule.staff.last_name}" if @schedule.staff.present?
  json.staff_role @schedule.staff.role_name if @schedule.staff.present?
  json.service_id service&.id
  json.service_name service&.name
  json.service_display_code service&.display_code 
  json.status @schedule.status
  json.date @schedule.date
  json.start_time @schedule.start_time
  json.end_time @schedule.end_time
  json.is_rendered @schedule.is_rendered
  json.unrendered_reasons @schedule.unrendered_reasons
  json.rendered_at @schedule.rendered_at
  json.units @schedule.units
  json.minutes @schedule.minutes
  if @schedule.client_enrollment_service.present? && @schedule.client_enrollment_service.staff.present?
    json.service_providers do
      json.array! @schedule.client_enrollment_service.staff do |staff|
        json.id staff.id
        json.name "#{staff.first_name} #{staff.last_name}"
        json.role staff.role_name
      end
    end
  end
  if @schedule.creator_id.present?
    creator = User.find(@schedule.creator_id)
    json.creator_id @schedule.creator_id
    json.creator_name "#{creator&.first_name} #{creator&.last_name}"
  else
    json.creator_id nil
    json.creator_name nil
  end
  if @schedule.updator_id.present?
    updator = User.find(@schedule.updator_id)
    json.updator_id @schedule.updator_id
    json.updator_name "#{updator&.first_name} #{updator&.last_name}"
  else
    json.updator_id nil
    json.updator_name nil
  end
end
