json.status @schedule.errors.any? ? 'failure' : 'success'
json.data do
  client = @schedule.client_enrollment_service&.client_enrollment&.client
  service = @schedule.client_enrollment_service&.service
  json.id @schedule.id
  json.client_enrollment_service_id @schedule.client_enrollment_service_id
  json.cross_site_allowed @schedule.cross_site_allowed
  json.client_id client&.id
  json.client_name "#{client.first_name} #{client.last_name}" if client.present?
  json.service_address_id @schedule.service_address_id
  json.service_address @schedule.service_address
  json.staff_id @schedule.staff_id
  json.staff_name "#{@schedule.staff.first_name} #{@schedule.staff.last_name}" if @schedule.staff.present?
  json.service_id service&.id
  json.service_name service&.name
  json.service_display_code service&.display_code 
  json.is_early_code service&.is_early_code
  json.status @schedule.status
  json.date @schedule.date
  json.start_time @schedule.start_time
  json.end_time @schedule.end_time
  # json.is_rendered @schedule.is_rendered
  if @schedule.rendered_at.present? && @schedule.status == 'rendered'
    json.is_rendered true
  else
    json.is_rendered false
  end
  json.unrendered_reasons @schedule.unrendered_reason
  json.units @schedule.units
  json.minutes @schedule.minutes
  if @schedule.creator_id.present?
    creator = User.find_by(id: @schedule.creator_id)
    json.creator_id @schedule.creator_id
    json.creator_name "#{creator&.first_name} #{creator&.last_name}"
  else
    json.creator_id nil
    json.creator_name nil
  end
  if @schedule.updator_id.present?
    updator = User.find_by(id: @schedule.updator_id)
    json.updator_id @schedule.updator_id
    json.updator_name "#{updator&.first_name} #{updator&.last_name}"
  else
    json.updator_id nil
    json.updator_name nil
  end
  json.soap_notes do
    json.array! @schedule.soap_notes do |soap_note|
      user = User.find_by(id: soap_note.creator_id)
      json.id soap_note.id
      json.scheduling_id soap_note.scheduling_id
      json.note soap_note.note
      json.add_date soap_note.add_date
      json.rbt_sign soap_note.rbt_signature
      json.rbt_sign_name soap_note.rbt_signature_author_name
      json.rbt_sign_date soap_note.rbt_signature_date
      json.bcba_sign soap_note.bcba_signature
      json.bcba_sign_name soap_note.bcba_signature_author_name
      json.bcba_sign_date soap_note.bcba_signature_date&.strftime('%Y-%m-%d %H:%M')
      json.clinical_director_sign soap_note.clinical_director_signature
      json.clinical_director_sign_name soap_note.clinical_director_signature_author_name
      json.clinical_director_sign_date soap_note.clinical_director_signature_date
      json.caregiver_sign soap_note.signature_file&.blob&.service_url
      json.caregiver_sign_date soap_note.caregiver_signature_datetime
      json.creator_id user&.id
      json.creator "#{user&.first_name} #{user&.last_name}"
      json.caregiver_sign_present soap_note.caregiver_signature if soap_note.synced_with_catalyst.to_bool.true?
    end
  end
end
json.errors @schedule.errors.full_messages
