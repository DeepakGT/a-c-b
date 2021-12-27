json.status @organization.errors.any? ? 'failure' : 'success'
json.data do
  json.id @organization.id
  json.name @organization.name
end
json.errors @organization.errors.full_messages
