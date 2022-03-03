json.status @soap_note.errors.any? ? 'failure' : 'success'
json.data do
  user = User.find(@soap_note.creator_id)
  json.id @soap_note.id
  json.scheduling_id @soap_note.scheduling_id
  json.note @soap_note.note
  json.add_date @soap_note.add_date
  json.creator_id user&.id
  json.creator "#{user&.first_name} #{user&.last_name}"
end
json.errors @soap_note.errors.full_messages
