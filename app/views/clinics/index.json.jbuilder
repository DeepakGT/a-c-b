json.status 'success'
json.data do
  json.array! @clinics do |clinic|
    json.id clinic.id
    json.name clinic.name
    json.organization_id clinic.organization_id
    json.organization_name clinic.organization_name
    json.aka clinic.aka
    json.web clinic.web
    json.email clinic.email
    json.status clinic.status
    if clinic.phone_number.present?
      json.phone_number do
        json.id clinic.phone_number.id
        json.phone_type clinic.phone_number.phone_type
        json.number clinic.phone_number.number
      end
    end
    if clinic.address.present?
      json.address do
        json.id clinic.address.id
        json.line1 clinic.address.line1
        json.line2 clinic.address.line2
        json.line3 clinic.address.line3
        json.zipcode clinic.address.zipcode
        json.city clinic.address.city
        json.state clinic.address.state
        json.country clinic.address.country
      end
    end
  end
end
if params[:page].present?
  json.total_records @clinics.total_entries
  json.limit @clinics.per_page
  json.page params[:page]
end
