json.status 'success'
json.data do
  json.id @staff_credential.id
  json.name @staff_credential.credential.name
  json.credential_id @staff_credential.credential_id
  json.issued_at @staff_credential.issued_at
  json.expires_at @staff_credential.expires_at
  json.cert_lic_number @staff_credential.cert_lic_number
  json.documentation_notes @staff_credential.documentation_notes
end
