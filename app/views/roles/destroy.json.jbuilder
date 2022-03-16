json.status 'success'
json.data do
  json.id @role.id
  json.name @role.name
  json.permissions @role.permissions
end
