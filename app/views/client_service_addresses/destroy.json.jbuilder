json.status @service_address.errors.any? ? 'failure' : 'success'
json.data do
  json.partial! 'service_address_detail', service_address: @service_address
end
json.errors @service_address.errors.full_messages
