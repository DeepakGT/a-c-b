if @organization.errors.any?
  json.status 'failure'
  json.errors @organization.errors.full_messages
else
  json.status 'success'
  json.data do
    json.id @organization.id
    json.name @organization.name
  end
end
