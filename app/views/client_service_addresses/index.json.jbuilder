json.status 'success'
json.data do
  if @service_addresses.where(address_name: 'Office').present?
    json.office_address true
  else
    json.office_address false
  end
  json.array! @service_addresses do |address|
    json.id address.id
    json.client_id address.addressable_id
    json.type address.address_type
    json.line1 address.line1
    json.line2 address.line2
    json.line3 address.line3
    json.zipcode address.zipcode
    json.city address.city
    json.state address.state
    json.country address.country
    json.is_default address.is_default
    json.is_hidden address.is_hidden
    if Scheduling.where(service_address_id: address.id).blank?
      json.associated_with_appointment false
    else
      json.associated_with_appointment true
    end
    json.address_name address.address_name
  end
end
