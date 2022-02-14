json.status 'success'
json.data do
  json.array! @attachments do |attachment|
    json.id attachment.id
    json.client_id attachment.attachable_id
    json.category attachment.category
    json.url attachment.file.blob.service_url
  end
end
