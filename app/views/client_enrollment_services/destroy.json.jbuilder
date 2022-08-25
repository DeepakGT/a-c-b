json.status 'success'
json.data do
  json.partial! 'client_enrollment_service_detail', enrollment_service: @enrollment_service
  json.partial! 'service_provider_detail', enrollment_service: @enrollment_service, object_type: nil
end
