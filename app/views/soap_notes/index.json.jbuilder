json.status 'success'
json.data do
  json.array! @soap_notes do |soap_note|
    user = User.find(soap_note.creator_id)
    json.id soap_note.id
    json.scheduling_id soap_note.scheduling_id
    json.note soap_note.note
    json.add_date soap_note.add_date
    json.add_time soap_note.add_time&.strftime('%H:%M')
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
    json.synced_with_catalyst soap_note.synced_with_catalyst
    if soap_note.synced_with_catalyst.to_bool.true?
      json.caregiver_sign_present soap_note.caregiver_signature
      catalyst_data = CatalystData.find_by(id: soap_note.catalyst_data_id)
      json.location catalyst_data&.session_location
      json.cordinates catalyst_data&.location
    else
      json.location nil
      json.cordinates nil
    end
  end
end
