json.status 'success'
json.data do
  json.array! @countries do |country|
    json.id country.id
    json.name country.name
  end
end
