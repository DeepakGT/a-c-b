json.status @client_note.errors.any? ? 'failure' : 'success'
json.data do
  json.id @client_note.id
  json.client_id @client_note.client_id
  json.note @client_note.note
  json.add_date @client_note.add_date
end
json.errors @client_note.errors.full_messages
