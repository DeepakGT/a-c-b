json.status 'success'
json.data do
  json.partial! 'soap_notes/soap_note_detail', soap_note: @soap_note
end
