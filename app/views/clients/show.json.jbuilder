client_enrollment = @client.client_enrollments.order(is_primary: :desc).first
json.status 'success'
json.data do
  json.id @client.id
  json.first_name @client.first_name
  json.last_name @client.last_name
  json.email @client.email
  json.clinic_id @client.clinic_id
  json.clinic_name @client.clinic.name
  json.email @client.email
  json.dob @client.dob
  json.gender @client.gender
  json.status @client.status
  json.preferred_language @client.preferred_language
  json.disqualified @client.disqualified
  json.disqualified_reason @client.dq_reason if @client.disqualified?
  if client_enrollment.present?
    if client_enrollment.source_of_payment=='self_pay'
      json.payor_status client_enrollment.source_of_payment
    else
      json.payor_status client_enrollment.funding_source.name
    end
  end
  if @client.contacts.present?
    json.contact do
      json.id @client.contacts.first.id
      json.first_name @client.contacts.first.first_name
      json.last_name @client.contacts.first.last_name
      json.email @client.contacts.first.email
      json.client_id @client.contacts.first.client_id
      json.type @client.contacts.first.relation_type
      json.relation @client.contacts.first.relation
      json.legal_guardian @client.contacts.first.legal_guardian
      json.guarantor @client.contacts.first.guarantor
      json.parent_portal_access @client.contacts.first.parent_portal_access
      json.resides_with_client @client.contacts.first.resides_with_client
      if @client.contacts.first.phone_numbers.present?
        json.phone_numbers do
          json.array! @client.contacts.first.phone_numbers do |phone_number|
            json.id phone_number.id
            json.phone_type phone_number.phone_type
            json.number phone_number.number
          end
        end
      end
    end
  end
  if @client.addresses.present?
    json.addresses do
      json.array! @client.addresses do |address|
        json.id address.id
        json.type address.address_type
        json.line1 address.line1
        json.line2 address.line2
        json.line3 address.line3
        json.zipcode address.zipcode
        json.city address.city
        json.state address.state
        json.country address.country
      end
    end
  end
  if @client.phone_number.present?
    json.phone_number do
      json.id @client.phone_number.id
      json.phone_type @client.phone_number.phone_type
      json.number @client.phone_number.number
    end
  end
end
