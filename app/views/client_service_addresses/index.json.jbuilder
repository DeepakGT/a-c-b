json.status 'success'
json.data do
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
  end
end
