json.status 'success'
json.data do
  json.partial! 'client_enrollment_detail', client_enrollment: @client_enrollment
  json.services do
    json.array! @client_enrollment.client_enrollment_services do |enrollment_service|
      json.partial! '/client_enrollment_services/client_enrollment_service_detail', enrollment_service: enrollment_service
    end
  end
end
