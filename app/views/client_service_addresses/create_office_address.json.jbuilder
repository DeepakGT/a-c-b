json.status @office_address.errors.any? ? 'failure' : 'success'
json.data do
  json.id @office_address.id
  json.client_id @office_address.addressable_id
  json.type @office_address.address_type
  json.line1 @office_address.line1
  json.line2 @office_address.line2
  json.line3 @office_address.line3
  json.zipcode @office_address.zipcode
  json.city @office_address.city
  json.state @office_address.state
  json.country @office_address.country
  json.is_default @office_address.is_default
  json.address_name @office_address.address_name
end
json.errors @office_address.errors.full_messages #&.map{|x| x.gsub!('Address ', '')}
