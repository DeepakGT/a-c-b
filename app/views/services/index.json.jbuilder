json.status 'success'
json.data do
  json.array! @services do |service|
    json.partial! 'service_detail', service: service
  end
end
json.partial! 'pagination_detail', list: @services, page_number: params[:page]
