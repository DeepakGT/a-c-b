json.status 'success'
json.data do
  json.partial! 'client_note_detail', client_note: @client_note
end
