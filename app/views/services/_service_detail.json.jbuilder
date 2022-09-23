json.id service.id
json.name service.name
json.status service.status
json.display_code service.display_code
json.is_service_provider_required service.is_service_provider_required
json.is_unassigned_appointment_allowed service.is_unassigned_appointment_allowed
json.selected_non_early_service_id service.selected_non_early_service_id
json.selected_payors JSON.parse(service.selected_payors) rescue nil if service.selected_payors.present?
json.is_early_code service.is_early_code
json.max_units service.max_units
json.allow_soap_notes_from_connect service.allow_soap_notes_from_connect
if service.qualifications.present?
  json.qualification_ids service.qualifications.pluck(:id)
  json.qualification_names service.qualifications.pluck(:name)
end
