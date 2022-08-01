json.status 'success'
json.data do
  json.partial! 'client_enrollment_service_detail', enrollment_service: @enrollment_service
end
