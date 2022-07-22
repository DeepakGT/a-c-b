if @service.reload.errors.any?
  json.status 'failure'
  json.errors @service.errors.full_messages
else
  json.status 'success'
  json.data do
    json.id @service.id
    json.name @service.name
    json.status @service.status
    json.display_code @service.display_code
    json.is_service_provider_required @service.is_service_provider_required
    json.is_unassigned_appointment_allowed @service.is_unassigned_appointment_allowed
    json.selected_non_early_services @service.selected_non_early_services
    json.selected_non_billable_payors @service.selected_non_billable_payors
    json.payors_requiring_rendering_provider @service.payors_requiring_rendering_provider
    if @service.qualifications.present?
      json.qualification_ids @service.qualifications.pluck(:id)
      json.qualification_names @service.qualifications.pluck(:name)
    end
  end
end
