json.status @client_note.errors.any? ? 'failure' : 'success'
json.data do
  json.partial! 'client_note_detail', client_note: @client_note
end
json.errors @client_note.errors.full_messages
