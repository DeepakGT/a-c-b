json.status 'success'
json.data do
  json.partial! 'service_address_detail', service_address: @service_address
  if Scheduling.where(service_address_id: @service_address.id).blank?
    json.associated_with_appointment false
  else
    json.associated_with_appointment true
  end
end
