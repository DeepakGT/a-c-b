json.status @soap_note.errors.any? ? 'failure' : 'success'
json.data do
  json.partial! 'soap_note_detail', soap_note: @soap_note
end
json.errors @soap_note.errors.full_messages
