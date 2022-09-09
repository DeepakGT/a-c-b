json.status 'success'
json.data do
  json.array! @funding_sources do |funding_source|
    json.partial! 'funding_source_detail', funding_source: funding_source
  end
end
json.partial! '/pagination_detail', list: @funding_sources, page_number: params[:page]
