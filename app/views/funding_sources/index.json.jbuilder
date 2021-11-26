json.status 'success'
json.data do
  json.array! @funding_sources do |funding_source|
    json.id funding_source.id
    json.name funding_source.name
  end
end
