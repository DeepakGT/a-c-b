json.status @client_enrollment_payment.errors.any? ? 'failure' : 'success'
json.data do
  json.id @client_enrollment_payment.id
  json.client_id @client_enrollment_payment.client_id
  json.source_of_payment @client_enrollment_payment.source_of_payment
  json.insurance @client_enrollment_payment.funding_source.name if @client_enrollment_payment.funding_source.present?
  json.insurance_id @client_enrollment_payment.insurance_id
  json.group @client_enrollment_payment.group
  json.group_employer @client_enrollment_payment.group_employer
  json.provider_phone @client_enrollment_payment.provider_phone
  json.relationship @client_enrollment_payment.relationship
  json.subscriber_name @client_enrollment_payment.subscriber_name
  json.subscriber_dob @client_enrollment_payment.subscriber_dob
  json.subscriber_phone @client_enrollment_payment.subscriber_phone
end
json.errors @client_enrollment_payment.errors.full_messages
