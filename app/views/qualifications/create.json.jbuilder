if @qualification.errors.any?
  json.status 'failure'
  json.errors @qualification.errors.full_messages
else
  json.status 'success'
  json.data do
    json.id @qualification.id
    json.type @qualification.credential_type
    json.name @qualification.name
    json.description @qualification.description
    json.lifetime @qualification.lifetime
  end
end
