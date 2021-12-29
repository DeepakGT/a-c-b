json.status 'success'
json.data do
  json.id @organization.id
  json.name @organization.name
end
