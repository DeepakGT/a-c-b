json.id client.id
json.first_name client.first_name
json.last_name client.last_name
json.clinic_id client.clinic_id
json.clinic_name client.clinic.name
json.bcba_id client.bcba_id
json.bcba_name "#{client.bcba&.first_name} #{client.bcba&.last_name}"
json.email client.email
json.dob client.dob
json.gender client.gender
json.status client.status
json.tracking_id client.tracking_id
json.preferred_language client.preferred_language
json.disqualified client.disqualified
json.disqualified_reason client.dq_reason if client.disqualified?
json.payor_status client.payor_status
if client.addresses.present?
  json.addresses do
    json.array! client.addresses do |address|
      json.id address.id
      json.type address.address_type
      json.line1 address.line1
      json.line2 address.line2
      json.line3 address.line3
      json.zipcode address.zipcode
      json.city address.city
      json.state address.state
      json.country address.country
      if address.address_type.service_address?
        json.is_default address.is_default 
        json.is_hidden address.is_hidden
      end
    end
  end
end
if client.phone_number.present?
  json.phone_number do
    json.id client.phone_number.id
    json.phone_type client.phone_number.phone_type
    json.number client.phone_number.number
  end
end
