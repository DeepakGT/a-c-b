json.status 'success'
json.data do
  json.id @client_enrollment.id
  json.client_id @client_enrollment.client_id
  json.funding_source_id @client_enrollment.funding_source_id
  json.funding_source @client_enrollment.funding_source.name
  json.enrollment_date @client_enrollment.enrollment_date
  json.terminated_at @client_enrollment.terminated_at
  json.insureds_name @client_enrollment.insureds_name
  json.notes @client_enrollment.notes
  json.top_invoice_note @client_enrollment.top_invoice_note
  json.bottom_invoice_note @client_enrollment.bottom_invoice_note
end
