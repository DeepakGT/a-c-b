json.status @attachment_category.errors.any? ? 'failure' : 'success'
json.data do
  json.id @attachment_category.id
  json.name @attachment_category.name
  json.create_at @attachment_category.created_at
  json.update_at @attachment_category.updated_at
end
json.errors @attachment_category.errors.full_messages
