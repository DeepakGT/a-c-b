json.id enrollment_service.id
json.client_enrollment_id enrollment_service.client_enrollment_id
json.funding_source_id enrollment_service.client_enrollment.funding_source_id
json.funding_source enrollment_service.client_enrollment.funding_source&.name
json.service_id enrollment_service.service_id
json.service enrollment_service.service&.name
json.service_display_code enrollment_service.service&.display_code
json.is_service_provider_required enrollment_service.service&.is_service_provider_required
json.start_date enrollment_service.start_date
json.end_date enrollment_service.end_date
json.units enrollment_service.units
json.used_units enrollment_service.used_units
json.scheduled_units enrollment_service.scheduled_units
json.left_units enrollment_service.left_units
json.minutes enrollment_service.minutes
json.used_minutes enrollment_service.used_minutes
json.scheduled_minutes enrollment_service.scheduled_minutes
json.left_minutes enrollment_service.left_minutes
json.service_number enrollment_service.service_number
json.service_providers do
  json.array! enrollment_service.service_providers do |service_provider|
    json.id service_provider.staff_id
    json.name "#{service_provider.staff&.first_name} #{service_provider.staff&.last_name}"
  end 
end
