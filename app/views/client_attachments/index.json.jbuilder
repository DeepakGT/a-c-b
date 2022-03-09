json.status 'success'
json.data do
  json.array! @attachments do |attachment|
    json.id attachment.id
    json.client_id attachment.attachable_id
    json.category attachment.category
    json.file_name attachment.file_name
    json.url attachment.file.blob&.service_url
    json.add_date attachment.created_at.to_date
  end
end
