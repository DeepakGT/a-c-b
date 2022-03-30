json.status 'success'
json.data do
  json.id @service_address.id
  json.client_id @service_address.addressable_id
  json.type @service_address.address_type
  json.line1 @service_address.line1
  json.line2 @service_address.line2
  json.line3 @service_address.line3
  json.zipcode @service_address.zipcode
  json.city @service_address.city
  json.state @service_address.state
  json.country @service_address.country
  json.is_default @service_address.is_default
  json.address_name @service_address.address_name
end
