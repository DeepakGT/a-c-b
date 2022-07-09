json.status 'success'
json.data do
  user = User.where(id: @client_note.creator_id)&.first
  json.id @client_note.id
  json.client_id @client_note.client_id
  json.note @client_note.note
  json.add_date @client_note.add_date
  json.creator_id user&.id
  json.creator "#{user&.first_name} #{user&.last_name}"
end
