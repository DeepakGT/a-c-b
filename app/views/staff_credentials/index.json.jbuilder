json.status 'success'
json.data do
  json.array! @credentials do |credential|
    json.id credential.staff_credentials.by_user(@staff).id
    json.name credential.name
    json.issued_at credential.staff_credentials.by_user(@staff).issued_at
    json.expires_at credential.staff_credentials.by_user(@staff).expires_at
    json.cert_lic_number credential.staff_credentials.by_user(@staff).cert_lic_number
    json.documentation_notes credential.staff_credentials.by_user(@staff).documentation_notes
  end
end
