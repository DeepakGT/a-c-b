json.status 'success'
json.data do
  json.partial! 'service_detail', service: @service
end
