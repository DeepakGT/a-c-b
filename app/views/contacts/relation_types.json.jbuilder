json.status 'success'
json.data do
  json.array! @relation_types do |relation_type|
    json.id relation_type.last
    json.type relation_type.first
  end
end
