json.status 'success'
json.data do
  json.id @attachment.id
  json.client_id @attachment.attachable_id
  json.category @attachment.category
  json.url @attachment.file.blob.service_url
end
