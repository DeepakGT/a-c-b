json.status 'success'
json.data do
  user = User.find(@soap_note.creator_id)
  json.id @soap_note.id
  json.scheduling_id @soap_note.scheduling_id
  json.note @soap_note.note
  json.add_date @soap_note.add_date
  json.rbt_sign @soap_note.rbt_sign
  if @soap_note.rbt_sign.to_bool.true?
    json.rbt_sign_name @soap_note.rbt_sign_name
    json.rbt_sign_date @soap_note.rbt_sign_date
  end
  json.bcba_sign @soap_note.bcba_sign
  if @soap_note.bcba_sign.to_bool.true?
    json.bcba_sign_name @soap_note.bcba_sign_name
    json.bcba_sign_date @soap_note.bcba_sign_date
  end
  json.clinical_director_sign @soap_note.clinical_director_sign
  if @soap_note.clinical_director_sign.to_bool.true?
    json.clinical_director_sign_name @soap_note.clinical_director_sign_name
    json.clinical_director_sign_date @soap_note.clinical_director_sign_date
  end
  if @soap_note.signature_file.attached?
    json.caregiver_sign @soap_note.signature_file&.blob&.service_url
  end
  json.creator_id user&.id
  json.creator "#{user&.first_name} #{user&.last_name}"
end
