json.status 'success'
json.data do
  if @final_authorization.present?
    json.final_authorization do
      json.partial! 'client_enrollment_services/client_enrollment_service_detail', enrollment_service: @final_authorization
      json.partial! 'service_provider_detail', enrollment_service: @final_authorization, object_type: 'arrays'
    end
  end
  if @early_authorization.reload.present?
    json.early_authorization do
      json.partial! 'client_enrollment_services/client_enrollment_service_detail', enrollment_service: @early_authorization
      json.partial! 'service_provider_detail', enrollment_service: @early_authorization, object_type: 'arrays'
    end
  end
end
