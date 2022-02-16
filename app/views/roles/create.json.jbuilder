json.status @role.errors.any? ? 'failure' : 'success'
json.data do
  json.id @role.id
  json.name @role.name
  json.permissions @role.permissions
end
json.errors @role.errors.full_messages
