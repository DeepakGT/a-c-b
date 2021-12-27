json.status 'success'
json.data do
  json.array! @phone_types do |phone_type|
    json.id phone_type.last
    json.type phone_type.first
  end
end
