primary_client_enrollment = @client.client_enrollments.active.order(is_primary: :desc).first
json.status 'success'
json.data do
  json.partial! 'client_detail', client: @client
  if primary_client_enrollment.present?
    if primary_client_enrollment.source_of_payment=='self_pay' || primary_client_enrollment.funding_source.blank?
      json.payor nil
    else
      json.payor primary_client_enrollment.funding_source.name
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
end
