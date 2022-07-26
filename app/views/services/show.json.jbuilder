json.status 'success'
json.data do
  json.id @service.id
  json.name @service.name
  json.status @service.status
  json.display_code @service.display_code
  json.is_service_provider_required @service.is_service_provider_required
  json.is_unassigned_appointment_allowed @service.is_unassigned_appointment_allowed
  json.selected_non_early_services @service.selected_non_early_services
  json.selected_payors @service.selected_payors
  json.selected_payors_names FundingSource.where(id: @service.selected_payors).pluck(:name)
  json.max_units @service.max_units
  json.is_early_code @service.is_early_code
  if @service.qualifications.present?
    json.qualification_ids @service.qualifications.pluck(:id)
    json.qualification_names @service.qualifications.pluck(:name)
  end
end
