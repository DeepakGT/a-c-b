json.status 'success'
json.data do
  json.array! @funding_sources do |funding_source|
    json.partial! 'funding_source_detail', funding_source: funding_source
  end
end
if params[:page].present?
  json.total_records @funding_sources.total_entries
  json.limit @funding_sources.per_page
  json.page params[:page]
end
