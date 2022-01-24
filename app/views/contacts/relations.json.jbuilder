json.status 'success'
json.data do
  json.array! @relations do |relation|
    json.id relation.last
    json.type relation.first
  end
end
