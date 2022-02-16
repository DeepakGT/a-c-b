json.status 'success'
json.data do
  json.array! @client_notes do |client_note|
    json.id client_note.id
    json.client_id client_note.client_id
    json.note client_note.note
    json.add_date client_note.add_date
  end
end
