json.status 'success'
json.data do
  json.array! @services do |service|
    json.partial! 'service_detail', service: service
  end
end
if params[:page].present?
  json.total_records @services.total_entries
  json.limit @services.per_page
  json.page params[:page]
end
