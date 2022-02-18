json.status 'success'
json.data do
  json.id @enrollment_service.id
  json.client_enrollment_id @enrollment_service.client_enrollment_id
  json.funding_source_id @enrollment_service.client_enrollment.funding_source_id
  json.funding_source @enrollment_service.client_enrollment.funding_source.name
  json.service_id @enrollment_service.service_id
  json.service @enrollment_service.service.name
  json.start_date @enrollment_service.start_date
  json.end_date @enrollment_service.end_date
  json.units @enrollment_service.units
  json.minutes @enrollment_service.minutes
  json.service_number @enrollment_service.service_number
  json.service_providers do
    json.ids @enrollment_service.service_providers.pluck(:id)
    json.staff_ids @enrollment_service.service_providers.pluck(:staff_id)
    json.names @enrollment_service.staff.map{|staff| "#{staff.first_name} #{staff.last_name}"}
  end
end
