json.status 'success'
json.data do
  json.id @service.id
  json.name @service.name
  json.status @service.status
  json.display_code @service.display_code
  json.allow_soap_notes_from_connect @service.allow_soap_notes_from_connect
  json.is_service_provider_required @service.is_service_provider_required
  json.is_unassigned_appointment_allowed @service.is_unassigned_appointment_allowed
  if @service.qualifications.present?
    json.qualification_ids @service.qualifications.pluck(:id)
    json.qualification_names @service.qualifications.pluck(:name)
  end
end
