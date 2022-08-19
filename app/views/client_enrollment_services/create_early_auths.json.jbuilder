json.status @client.reload.errors.any? ? 'failure' : 'success'
json.data do
  if @client_enrollment.present?
    json.partial! 'client_enrollments/client_enrollment_detail', client_enrollment: @client_enrollment
    json.services do
      json.array! @client_enrollment.client_enrollment_services do |enrollment_service|
        json.partial! 'client_enrollment_service_detail', enrollment_service: enrollment_service
        json.partial! 'service_provider_detail', enrollment_service: enrollment_service, object_type: 'arrays'
      end
    end
  end
end
json.errors @client.errors.full_messages
