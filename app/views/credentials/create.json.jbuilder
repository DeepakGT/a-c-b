if @credential.errors.any?
  json.status 'false'
  json.errors @credential.errors.full_messages
else
  json.status 'success'
  json.data do
    json.id @credential.id
    json.type @credential.credential_type
    json.name @credential.name
    json.description @credential.description
    json.lifetime @credential.lifetime
  end
end
