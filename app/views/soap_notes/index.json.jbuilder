json.status 'success'
json.data do
  json.array! @soap_notes do |soap_note|
    user = User.find(soap_note.creator_id)
    json.id soap_note.id
    json.scheduling_id soap_note.scheduling_id
    json.note soap_note.note
    json.add_date soap_note.add_date
    json.creator_id user&.id
    json.creator "#{user&.first_name} #{user&.last_name}"
  end
end
