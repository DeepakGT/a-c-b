json.status @soap_note.errors.any? ? 'failure' : 'success'
json.data do
  user = User.find(@soap_note.creator_id)
  json.id @soap_note.id
  json.scheduling_id @soap_note.scheduling_id
  json.note @soap_note.note
  json.add_date @soap_note.add_date
  json.rbt_sign @soap_note.rbt_signature
  json.rbt_sign_name @soap_note.rbt_signature_author_name
  json.rbt_sign_date @soap_note.rbt_signature_date
  json.bcba_sign @soap_note.bcba_signature
  json.bcba_sign_name @soap_note.bcba_signature_author_name
  json.bcba_sign_date @soap_note.bcba_signature_date&.strftime('%Y-%m-%d %H:%M')
  json.clinical_director_sign @soap_note.clinical_director_signature
  json.clinical_director_sign_name @soap_note.clinical_director_signature_author_name
  json.clinical_director_sign_date @soap_note.clinical_director_signature_date
  json.caregiver_sign @soap_note.signature_file&.blob&.service_url
  json.caregiver_sign_date @soap_note.caregiver_signature_datetime
  json.creator_id user&.id
  json.creator "#{user&.first_name} #{user&.last_name}"
  if @soap_note.scheduling.is_rendered==true
    json.rendered_message "Soap note has been created and Appointment has been rendered successfully."
  elsif @soap_note.scheduling.unrendered_reason.present?
    message = "Appointment has been updated but cannot be rendered because #{@soap_note.scheduling.unrendered_reason.to_human_string}"
    message.gsub!('absent', 'not found')
    message.gsub!('_',' ')
    json.rendered_message message
  end
end
json.errors @soap_note.errors.full_messages
