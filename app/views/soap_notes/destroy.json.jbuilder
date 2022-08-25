json.status 'success'
json.data do
  json.partial! 'soap_note_detail', soap_note: @soap_note
end
