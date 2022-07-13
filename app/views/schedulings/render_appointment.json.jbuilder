json.status 'success'
json.data do
  client = @schedule.client_enrollment_service&.client_enrollment&.client
  service = @schedule.client_enrollment_service&.service
  # schedules = Scheduling.by_client_and_service(@schedule.client_enrollment_service.client_enrollment.client_id, @schedule.client_enrollment_service.service_id)
  # schedules = schedules.with_rendered_or_scheduled_as_status
  # completed_schedules = schedules.completed_scheduling
  # scheduled_schedules = schedules.scheduled_scheduling
  # used_units = completed_schedules.with_units.pluck(:units).sum
  # scheduled_units = scheduled_schedules.with_units.pluck(:units).sum
  # used_minutes = completed_schedules.with_minutes.pluck(:minutes).sum
  # scheduled_minutes = scheduled_schedules.with_minutes.pluck(:minutes).sum
  json.id @schedule.id
  json.client_enrollment_service_id @schedule.client_enrollment_service_id
  json.total_units @schedule.client_enrollment_service.units
  json.used_units @schedule.client_enrollment_service.used_units
  json.scheduled_units @schedule.client_enrollment_service.scheduled_units
  json.left_units @schedule.client_enrollment_service.left_units
  # if @schedule.client_enrollment_service.units.present?
  #   json.left_units @schedule.client_enrollment_service.units - (used_units + scheduled_units) 
  # else
  #   json.left_units 0
  # end
  json.total_minutes @schedule.client_enrollment_service.minutes
  json.used_minutes @schedule.client_enrollment_service.used_minutes
  json.scheduled_minutes @schedule.client_enrollment_service.scheduled_minutes
  json.left_minutes @schedule.client_enrollment_service.left_minutes
  # if @schedule.client_enrollment_service.minutes.present?
  #   json.left_minutes @schedule.client_enrollment_service.minutes - (used_minutes + scheduled_minutes)
  # else
  #   json.left_minutes 0
  # end
  json.cross_site_allowed @schedule.cross_site_allowed
  json.client_id client&.id
  json.client_name "#{client.first_name} #{client.last_name}" if client.present?
  json.service_address_id @schedule.service_address_id
  if @schedule.service_address_id.present?
    service_address = Address.find_by(id: @schedule.service_address_id)
    if service_address.present?
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
  end
  json.staff_id @schedule.staff_id
  json.staff_name "#{@schedule.staff.first_name} #{@schedule.staff.last_name}" if @schedule.staff.present?
  json.staff_role @schedule.staff.role_name if @schedule.staff.present?
  json.staff_email @schedule.staff.email if @schedule.staff.present?
  json.service_id service&.id
  json.service_name service&.name
  json.service_display_code service&.display_code 
  json.status @schedule.status
  json.date @schedule.date
  json.start_time @schedule.start_time.to_time.strftime('%H:%M')
  json.end_time @schedule.end_time.to_time.strftime('%H:%M')
  # json.is_rendered @schedule.is_rendered
  if @schedule.rendered_at.present?
    json.is_rendered true
  else
    json.is_rendered false
  end
  json.is_manual_render @schedule.is_manual_render
  json.unrendered_reasons @schedule.unrendered_reason
  json.rendered_at @schedule.rendered_at
  rendered_by_staff = User.find_by(id: @schedule.rendered_by_id)
  json.rendered_by "#{rendered_by_staff&.first_name} #{rendered_by_staff&.last_name}"
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
    creator = User.find_by(id: @schedule.creator_id)
    json.creator_id @schedule.creator_id
    json.creator_name "#{creator&.first_name} #{creator&.last_name}"
  else
    json.creator_id nil
    json.creator_name nil
  end
  if @schedule.updator_id.present?
    updator = User.find_by(id: @schedule.updator_id)
    json.updator_id @schedule.updator_id
    json.updator_name "#{updator&.first_name} #{updator&.last_name}"
  else
    json.updator_id nil
    json.updator_name nil
  end
end