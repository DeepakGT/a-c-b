if @staff_credential.errors.any?
  json.status 'failure'
  json.errors @staff_credential.errors.full_messages
else
  json.status 'success'
  json.data do
    json.id @staff_credential.id
    json.name @staff_credential.credential.name
    json.issued_at @staff_credential.issued_at
    json.expires_at @staff_credential.expires_at
    json.cert_lic_number @staff_credential.cert_lic_number
    json.documentation_notes @staff_credential.documentation_notes
  end
end