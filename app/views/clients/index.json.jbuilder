json.status 'success'
json.data do
  json.array! @clients do |client|
    primary_client_enrollment = client.client_enrollments.active.order(is_primary: :desc).first
    json.id client.id
    json.first_name client.first_name
    json.last_name client.last_name
    json.email client.email
    json.clinic_id client.clinic_id
    json.clinic_name client.clinic.name
    json.bcba_id client.bcba_id
    json.bcba_name "#{client.bcba&.first_name} #{client.bcba&.last_name}"
    json.dob client.dob
    json.gender client.gender
    json.status client.status
    json.preferred_language client.preferred_language
    json.disqualified client.disqualified
    json.disqualified_reason client.dq_reason if client.disqualified?
    json.payor_status client.payor_status 
    if primary_client_enrollment.present?
      if primary_client_enrollment.source_of_payment=='self_pay' || primary_client_enrollment.funding_source.blank?
        json.payor nil
      else
        json.payor primary_client_enrollment.funding_source.name
      end
    end
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
          json.is_default address.is_default if address.address_type=='service_address'
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
  end
end
json.total_records @clients.total_entries
json.limit @clients.per_page
json.page params[:page] || 1
