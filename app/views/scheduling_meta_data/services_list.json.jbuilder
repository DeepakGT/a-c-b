json.status 'success'
json.data do
  json.array! @client_enrollment_services do |client_enrollment_service|
    schedules = Scheduling.by_client_and_service(client_enrollment_service.client_enrollment.client_id, client_enrollment_service.service_id)
    schedules = schedules.by_status
    completed_schedules = schedules.completed_scheduling
    scheduled_schedules = schedules.scheduled_scheduling
    used_units = completed_schedules.with_units.pluck(:units).sum
    scheduled_units = scheduled_schedules.with_units.pluck(:units).sum
    json.service_id client_enrollment_service.service.id
    json.name client_enrollment_service.service.name
    json.display_code client_enrollment_service.service.display_code
    json.is_service_provider_required client_enrollment_service.service.is_service_provider_required
    json.units client_enrollment_service.units
    json.used_units used_units
    json.scheduled_units scheduled_units
    if client_enrollment_service.units.present?
      json.left_units client_enrollment_service.units - (used_units + scheduled_units) 
    else
      json.left_units 0
    end
  end
end
