json.status 'success'
json.data do
  json.array! @regions do |region|
    json.id region.id
    json.region region.name
  end
end