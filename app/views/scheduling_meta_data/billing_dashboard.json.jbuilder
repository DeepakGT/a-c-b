json.status 'success'
json.data do
  if Setting.first&.roles_ids.include?(current_user&.role&.id)
    json.setting_data Setting.first&.welcome_note
  else
    json.setting_data nil
  end

  json.authorizations_expire_in_5_days do
    json.array! @authorizations_expire_in_5_days do |client_enrollment_service|
      json.partial! 'client_enrollment_service_detail', client_enrollment_service: client_enrollment_service
    end
  end
  json.authorizations_renewal_in_5_to_20_days do
    json.array! @authorizations_renewal_in_5_to_20_days do |client_enrollment_service|
      json.partial! 'client_enrollment_service_detail', client_enrollment_service: client_enrollment_service
    end
  end
  json.authorizations_renewal_in_21_to_60_days do
    json.array! @authorizations_renewal_in_21_to_60_days do |client_enrollment_service|
      json.partial! 'client_enrollment_service_detail', client_enrollment_service: client_enrollment_service
    end
  end
  json.client_with_no_authorizations do
    json.array! @client_with_no_authorizations do |client|
      primary_client_enrollment = client.client_enrollments.active&.order(is_primary: :desc)&.first
      json.partial! 'clients/client_detail', client: client
      if primary_client_enrollment.present?
        if primary_client_enrollment.source_of_payment=='self_pay' || primary_client_enrollment.funding_source.blank?
          json.payor nil
        else
          json.payor primary_client_enrollment.funding_source.name
        end
      end
    end
  end
  json.client_with_only_97151_service_authorization do
    json.array! @client_with_only_97151_service_authorization do |client|
      primary_client_enrollment = client.client_enrollments.active&.order(is_primary: :desc)&.first
      json.partial! 'clients/client_detail', client: client
      if primary_client_enrollment.present?
        if primary_client_enrollment.source_of_payment=='self_pay' || primary_client_enrollment.funding_source.blank?
          json.payor nil
        else
          json.payor primary_client_enrollment.funding_source.name
        end
      end
    end
  end
end
