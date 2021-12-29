json.status 'success'
json.data do
  json.array! @organizations do |organization|
    json.id organization.id
    json.name organization.name
  end
end
