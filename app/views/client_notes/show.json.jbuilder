json.status 'success'
json.data do
  json.id @client_note.id
  json.client_id @client_note.client_id
  json.note @client_note.note
  json.add_date @client_note.created_at.to_date
end
