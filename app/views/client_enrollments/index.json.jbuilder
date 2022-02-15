json.status 'success'
json.data do
  json.array! @client_enrollments do |client_enrollment|
    json.id client_enrollment.id
    json.client_id client_enrollment.client_id
    json.source_of_payment client_enrollment.source_of_payment
    json.funding_source_id client_enrollment.funding_source_id
    json.funding_source client_enrollment.funding_source.name
    json.primary client_enrollment.is_primary
    json.insurance_id client_enrollment.insurance_id
    json.group client_enrollment.group
    json.group_employer client_enrollment.group_employer
    json.provider_phone client_enrollment.provider_phone
    json.relationship client_enrollment.relationship
    json.subscriber_name client_enrollment.subscriber_name
    json.subscriber_phone client_enrollment.subscriber_phone
    json.subscriber_dob client_enrollment.subscriber_dob
  end
end
json.total_records @client_enrollments.total_entries
json.limit @client_enrollments.per_page
json.page params[:page] || 1
