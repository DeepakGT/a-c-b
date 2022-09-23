json.id client_enrollment_service.id
json.client_id client_enrollment_service.client_enrollment&.client_id
json.client_name "#{client_enrollment_service.client_enrollment&.client&.first_name} #{client_enrollment_service.client_enrollment&.client&.last_name}"
json.client_enrollment_id client_enrollment_service.client_enrollment_id
json.funding_source_id client_enrollment_service.client_enrollment.funding_source_id
json.funding_source client_enrollment_service.client_enrollment.funding_source&.name
json.service_id client_enrollment_service.service_id
json.service client_enrollment_service.service&.name
json.service_display_code client_enrollment_service.service&.display_code
json.is_early_code client_enrollment_service.service&.is_early_code
json.is_service_provider_required client_enrollment_service.service&.is_service_provider_required
json.start_date client_enrollment_service.start_date
json.end_date client_enrollment_service.end_date
json.units client_enrollment_service.units
json.used_units client_enrollment_service.used_units
json.scheduled_units client_enrollment_service.scheduled_units
json.left_units client_enrollment_service.left_units
json.minutes client_enrollment_service.minutes
json.used_minutes client_enrollment_service.used_minutes
json.scheduled_minutes client_enrollment_service.scheduled_minutes
json.left_minutes client_enrollment_service.left_minutes
json.service_number client_enrollment_service.service_number
json.service_providers do
  json.ids client_enrollment_service&.service_providers&.pluck(:id)
  json.staff_ids client_enrollment_service&.service_providers&.pluck(:staff_id)
  json.names client_enrollment_service&.staff&.map{|staff| "#{staff&.first_name} #{staff&.last_name}"}
end
