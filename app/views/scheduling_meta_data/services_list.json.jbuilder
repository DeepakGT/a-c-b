json.status 'success'
json.data do
  json.array! @client_enrollment_services do |client_enrollment_service|
    # schedules = Scheduling.by_client_and_service(client_enrollment_service.client_enrollment.client_id, client_enrollment_service.service_id)
    # schedules = schedules.with_rendered_or_scheduled_as_status
    # completed_schedules = schedules.completed_scheduling
    # scheduled_schedules = schedules.scheduled_scheduling
    # used_units = completed_schedules.with_units.pluck(:units).sum
    # scheduled_units = scheduled_schedules.with_units.pluck(:units).sum
    # used_minutes = completed_schedules.with_minutes.pluck(:minutes).sum
    # scheduled_minutes = scheduled_schedules.with_minutes.pluck(:minutes).sum
    json.client_enrollment_service_id client_enrollment_service.id
    json.service_id client_enrollment_service.service.id
    json.name client_enrollment_service.service.name
    json.display_code client_enrollment_service.service.display_code
    json.is_service_provider_required client_enrollment_service.service.is_service_provider_required
    json.units client_enrollment_service.units
    json.used_units client_enrollment_service.used_units
    json.scheduled_units client_enrollment_service.scheduled_units
    json.left_units client_enrollment_service.left_units
    # if client_enrollment_service.units.present?
    #   json.left_units client_enrollment_service.units - (used_units + scheduled_units) 
    # else
    #   json.left_units 0
    # end
    json.minutes client_enrollment_service.minutes
    json.used_minutes client_enrollment_service.used_minutes
    json.scheduled_minutes client_enrollment_service.scheduled_minutes
    json.left_minutes client_enrollment_service.left_minutes
    # if client_enrollment_service.minutes.present?
    #   json.left_minutes client_enrollment_service.minutes - (used_minutes + scheduled_minutes)
    # else
    #   json.left_minutes 0
    # end
    json.funding_source_name client_enrollment_service&.client_enrollment&.funding_source&.name 
    json.is_primary client_enrollment_service&.client_enrollment&.is_primary
    selected_payor = JSON.parse(client_enrollment_service&.service&.selected_payors)&.select{|payor| payor['payor_id']=="#{client_enrollment_service&.client_enrollment&.funding_source&.id}"}&.first
    json.is_legacy_required selected_payor['is_legacy_required'] if (client_enrollment_service&.service.is_service_provider_required.to_bool.true? && selected_payor.present? && @staff.present?)
  end
end
json.staff_legacy_number @staff&.legacy_number if @staff.present?
