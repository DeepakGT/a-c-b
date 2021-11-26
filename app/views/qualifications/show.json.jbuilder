if @qualification.present?
  json.status 'success'
  json.data do
    json.id @qualification.id
    json.tb_cleared_at @qualification.tb_cleared_at
    json.doj_cleared_at @qualification.doj_cleared_at
    json.fbi_cleared_at @qualification.fbi_cleared_at
    json.tb_expires_at @qualification.tb_expires_at
    json.doj_expires_at @qualification.doj_expires_at
    json.fbi_expires_at @qualification.fbi_expires_at
    json.credentials do
      json.array! @qualification.qualifications_credentials do |qualifications_credential|
        json.id qualifications_credential.credential.id
        json.name qualifications_credential.credential.name
        json.issued_at qualifications_credential.issued_at
        json.expires_at qualifications_credential.issued_at
        json.cert_lic_number qualifications_credential.cert_lic_number
        json.documentation_notes qualifications_credential.documentation_notes
      end
    end
    # json.funding_sources do
    #   json.array! @qualification.qualifications_funding_sources do |qualifications_funding_source|
    #     json.id qualifications_funding_source.funding_source.name
    #     json.name qualifications_funding_source.funding_source_type
    #   end
    # end
  end
else
  json.status 'failure'
  json.errors ['qualification not found.']
end
