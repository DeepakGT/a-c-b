json.status 'success'
json.data do
  json.array! @client_notes do |client_note|
    json.id client_note.id
    json.client_id client_note.client_id
    json.note client_note.note
    json.attachments do
      json.array! client_note.attachments do |attachment|
        json.url attachment.file.blob.service_url if attachment.file.attached?
      end
    end
  end
end
