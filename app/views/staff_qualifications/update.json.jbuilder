if @staff_qualification.errors.any?
  json.status 'failure'
  json.errors @staff_qualification.errors.full_messages
else
  json.status 'success'
  json.data do
    json.id @staff_qualification.id
    json.name @staff_qualification.qualification.name
    json.issued_on @staff_qualification.issued_on
    json.expires_on @staff_qualification.expires_on
    json.cert_lic_number @staff_qualification.cert_lic_number
    json.documentation_notes @staff_qualification.documentation_notes
  end
end
