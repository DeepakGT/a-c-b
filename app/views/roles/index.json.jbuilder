json.status 'success'
json.data do
  json.array! @roles do |role|
    json.id role.id
    json.name role.name
    json.permissions role.permissions
  end
end
