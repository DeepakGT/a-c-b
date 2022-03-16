json.status 'success'
json.data do
  json.array! @types do |type|
    json.id type.last
    json.type type.first
  end
end
