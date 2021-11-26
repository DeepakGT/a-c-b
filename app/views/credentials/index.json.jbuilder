json.status 'success'
json.data do
  json.array! @credentials do |credential|
    json.id credential.id
    json.type credential.credential
    json.name credential.name
    json.description credential.description
  end
end
