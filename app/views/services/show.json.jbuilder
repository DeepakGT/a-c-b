json.status 'success'
json.data do
  json.partial! 'service_detail', service: @service.reload
end
