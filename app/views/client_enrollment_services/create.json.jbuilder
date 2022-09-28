if @enrollment_service&.id.nil? || @early_authorization.blank?
  json.status @enrollment_service&.errors&.any? ? 'failure' : 'success'
  json.data do
    json.partial! 'client_enrollment_service_detail', enrollment_service: @enrollment_service
    json.partial! 'service_provider_detail', enrollment_service: @enrollment_service, object_type: nil
  end
  json.errors @enrollment_service&.errors&.full_messages
else
  if @early_authorization.present?
    json.status @early_authorization.reload.errors.any? ? 'failure' : 'success'
  else
    json.status 'success'
  end
  json.data do
    if @enrollment_service&.reload&.present?
      json.final_authorization do
        json.partial! 'client_enrollment_services/client_enrollment_service_detail', enrollment_service: @enrollment_service
        json.partial! 'service_provider_detail', enrollment_service: @enrollment_service, object_type: 'arrays'
      end
    end
    if @early_authorization.present?
      json.early_authorization do
        json.partial! 'client_enrollment_services/client_enrollment_service_detail', enrollment_service: @early_authorization
        json.partial! 'service_provider_detail', enrollment_service: @early_authorization, object_type: 'arrays'
      end
    end
  end
  json.errors @early_authorization&.errors&.full_messages  
end
