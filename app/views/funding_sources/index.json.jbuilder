json.status 'success'
json.data do
  json.array! @funding_sources do |funding_source|
    json.id funding_source.id
    json.name funding_source.name
    json.aka funding_source.aka
    json.title funding_source.title
    json.status funding_source.status
  end
end
json.total_records @funding_sources.total_entries
json.limit @funding_sources.per_page
json.page params[:page] || 1
