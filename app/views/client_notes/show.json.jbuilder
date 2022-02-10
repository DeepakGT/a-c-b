json.status 'success'
json.data do
  json.id @client_note.id
  json.client_id @client_note.client_id
  json.note @client_note.note
  if @client_note.attachment.present?
    json.attachment do
      json.url @client_note.attachment.file.blob.service_url if @client_note.attachment.file.attached?
    end
  end
end
