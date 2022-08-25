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
      json.partial! 'contacts/contact_detail', contact: @client&.contacts&.first
    end
  end
end
