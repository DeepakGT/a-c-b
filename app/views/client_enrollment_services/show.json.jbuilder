json.status 'success'
json.data do
  # schedules = Scheduling.by_client_and_service(@enrollment_service.client_enrollment.client_id, @enrollment_service.service_id)
  # schedules = schedules.with_rendered_or_scheduled_as_status
  # completed_schedules = schedules.completed_scheduling
  # scheduled_schedules = schedules.scheduled_scheduling
  # used_units = completed_schedules.with_units.pluck(:units).sum
  # scheduled_units = scheduled_schedules.with_units.pluck(:units).sum
  # used_minutes = completed_schedules.with_minutes.pluck(:minutes).sum
  # scheduled_minutes = scheduled_schedules.with_minutes.pluck(:minutes).sum
  json.id @enrollment_service.id
  json.client_enrollment_id @enrollment_service.client_enrollment_id
  json.funding_source_id @enrollment_service.client_enrollment.funding_source_id
  json.funding_source @enrollment_service.client_enrollment.funding_source&.name
  json.service_id @enrollment_service.service_id
  json.service @enrollment_service.service&.name
  json.service_display_code @enrollment_service.service&.display_code
  json.is_early_code @enrollment_service.service&.is_early_code
  json.is_service_provider_required @enrollment_service.service&.is_service_provider_required
  json.start_date @enrollment_service.start_date
  json.end_date @enrollment_service.end_date
  json.units @enrollment_service.units
  json.used_units @enrollment_service.used_units
  json.scheduled_units @enrollment_service.scheduled_units
  json.left_units @enrollment_service.left_units
  # if @enrollment_service.units.present?
  #   json.left_units @enrollment_service.units - (used_units + scheduled_units) 
  # else
  #   json.left_units 0
  # end
  json.minutes @enrollment_service.minutes
  json.used_minutes @enrollment_service.used_minutes
  json.scheduled_minutes @enrollment_service.scheduled_minutes
  json.left_minutes @enrollment_service.left_minutes
  # if @enrollment_service.minutes.present?
  #   json.left_minutes @enrollment_service.minutes - (used_minutes + scheduled_minutes)
  # else
  #   json.left_minutes 0
  # end
  json.service_number @enrollment_service.service_number
  json.service_providers do
    json.ids @enrollment_service.service_providers.pluck(:id)
    json.staff_ids @enrollment_service.service_providers.pluck(:staff_id)
    json.names @enrollment_service.staff&.map{|staff| "#{staff.first_name} #{staff.last_name}"}
  end
end
