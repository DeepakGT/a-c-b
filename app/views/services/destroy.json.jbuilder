json.status @service.errors.any? ? 'failure' : 'success'
json.data do
  json.partial! 'service_detail', service: @service
end
json.errors @service.errors.full_messages
