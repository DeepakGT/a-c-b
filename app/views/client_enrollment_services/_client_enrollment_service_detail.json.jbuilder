json.id enrollment_service&.id
json.client_enrollment_id enrollment_service&.client_enrollment_id
json.funding_source_id enrollment_service&.client_enrollment.funding_source_id
json.funding_source enrollment_service&.client_enrollment.funding_source&.name
json.service_id enrollment_service&.service_id
json.service enrollment_service&.service&.name
json.is_early_code enrollment_service&.service&.is_early_code
json.service_display_code enrollment_service&.service&.display_code
json.is_service_provider_required enrollment_service&.service&.is_service_provider_required
json.start_date enrollment_service&.start_date
json.end_date enrollment_service&.end_date
json.units enrollment_service&.units
json.used_units enrollment_service&.used_units
json.scheduled_units enrollment_service&.scheduled_units
json.left_units enrollment_service&.left_units
json.minutes enrollment_service&.minutes
json.used_minutes enrollment_service&.used_minutes
json.scheduled_minutes enrollment_service&.scheduled_minutes
json.left_minutes enrollment_service&.left_minutes
json.service_number enrollment_service&.service_number
if enrollment_service&.end_date.present? && enrollment_service&.end_date > (Time.current.to_date + 9)
  json.about_to_expire false
else
  json.about_to_expire true
end
if (enrollment_service&.used_units + enrollment_service&.scheduled_units)>=(0.9 * enrollment_service&.units)
  json.is_exhausted true
else
  json.is_exhausted false
end
