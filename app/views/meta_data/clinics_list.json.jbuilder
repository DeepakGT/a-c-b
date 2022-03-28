json.status 'success'
json.data do
  json.array! @clinics do |clinic|
    json.id clinic.id
    json.name clinic.name
    json.aka clinic.aka
    json.web clinic.web
    json.email clinic.email
    json.status clinic.status
    json.organization_id clinic.organization_id
    json.organization_name clinic.organization_name
  end
end
