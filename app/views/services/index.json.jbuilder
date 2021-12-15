json.status 'success'
json.data do
  json.array! @services do |service|
    json.id service.id
    json.name service.name
    json.status service.status
    json.display_code service.display_code
  end
end
json.total_records @services.total_entries
json.limit @services.per_page
json.page params[:page] || 1
