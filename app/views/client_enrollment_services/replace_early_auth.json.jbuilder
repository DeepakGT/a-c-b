json.status 'success'
json.data do
  if @final_authorization.reload.present?
    json.final_authorization do
      json.id @final_authorization.id
      json.client_enrollment_id @final_authorization.client_enrollment_id
      json.funding_source_id @final_authorization.client_enrollment.funding_source_id
      json.funding_source @final_authorization.client_enrollment.funding_source&.name
      json.service_id @final_authorization.service_id
      json.service @final_authorization.service&.name
      json.service_display_code @final_authorization.service&.display_code
      json.is_service_provider_required @final_authorization.service&.is_service_provider_required
      json.start_date @final_authorization.start_date
      json.end_date @final_authorization.end_date
      json.units @final_authorization.units
      json.used_units @final_authorization.used_units
      json.scheduled_units @final_authorization.scheduled_units
      json.left_units @final_authorization.left_units
      json.minutes @final_authorization.minutes
      json.used_minutes @final_authorization.used_minutes
      json.scheduled_minutes @final_authorization.scheduled_minutes
      json.left_minutes @final_authorization.left_minutes
      json.service_number @final_authorization.service_number
      json.service_providers do
        json.ids @final_authorization.service_providers.pluck(:id)
        json.staff_ids @final_authorization.service_providers.pluck(:staff_id)
        json.names @final_authorization.staff&.map{|staff| "#{staff.first_name} #{staff.last_name}"}
      end
    end
  end
  if @early_authorization.present?
    json.early_authorization do
      json.id @early_authorization.id
      json.client_enrollment_id @early_authorization.client_enrollment_id
      json.funding_source_id @early_authorization.client_enrollment.funding_source_id
      json.funding_source @early_authorization.client_enrollment.funding_source&.name
      json.service_id @early_authorization.service_id
      json.service @early_authorization.service&.name
      json.service_display_code @early_authorization.service&.display_code
      json.is_service_provider_required @early_authorization.service&.is_service_provider_required
      json.start_date @early_authorization.start_date
      json.end_date @early_authorization.end_date
      json.units @early_authorization.units
      json.used_units @early_authorization.used_units
      json.scheduled_units @early_authorization.scheduled_units
      json.left_units @early_authorization.left_units
      json.minutes @early_authorization.minutes
      json.used_minutes @early_authorization.used_minutes
      json.scheduled_minutes @early_authorization.scheduled_minutes
      json.left_minutes @early_authorization.left_minutes
      json.service_number @early_authorization.service_number
      json.service_providers do
        json.ids @early_authorization.service_providers.pluck(:id)
        json.staff_ids @early_authorization.service_providers.pluck(:staff_id)
        json.names @early_authorization.staff&.map{|staff| "#{staff.first_name} #{staff.last_name}"}
      end
    end
  end
end
