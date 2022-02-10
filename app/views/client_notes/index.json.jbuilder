json.status 'success'
json.data do
  json.array! @client_notes do |client_note|
    json.id client_note.id
    json.client_id client_note.client_id
    json.note client_note.note
    json.add_date client_note.created_at.to_date
    if client_note.attachment.present?
      json.attachment do
        json.category client_note.attachment.category
        json.url client_note.attachment.file.blob.service_url if client_note.attachment.file.attached?
      end
    end
  end
end
