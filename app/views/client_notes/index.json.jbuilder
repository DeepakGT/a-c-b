json.status 'success'
json.data do
  json.array! @client_notes do |client_note|
    json.partial! 'client_note_detail', client_note: client_note
  end
end
