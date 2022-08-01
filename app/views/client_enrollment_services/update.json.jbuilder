json.status @enrollment_service.errors.any? ? 'failure' : 'success'
json.data do
  json.partial! 'client_enrollment_service_detail', enrollment_service: @enrollment_service.reload, action: 'update'
end
json.errors @enrollment_service.errors.full_messages
