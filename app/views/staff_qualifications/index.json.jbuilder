json.status 'success'
json.data do
  json.array! @qualifications do |qualification|
    json.id qualification.staff_qualifications.by_user(@staff).id
    json.name qualification.name
    json.credential_id qualification.id
    json.issued_at qualification.staff_qualifications.by_user(@staff).issued_at
    json.expires_at qualification.staff_qualifications.by_user(@staff).expires_at
    json.cert_lic_number qualification.staff_qualifications.by_user(@staff).cert_lic_number
    json.documentation_notes qualification.staff_qualifications.by_user(@staff).documentation_notes
  end
end
