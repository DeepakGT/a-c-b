json.status 'success'
json.data @regions do |region|
  json.id region.id
  json.region region.name
end
