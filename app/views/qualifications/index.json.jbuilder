json.status 'success'
json.data do
  json.array! @qualifications do |qualification|
    json.id qualification.id
    json.type qualification.credential_type
    json.name qualification.name
    json.description qualification.description
    json.lifetime qualification.lifetime
  end
end
if params[:page].present?
  json.total_records @qualifications.total_entries
  json.limit @qualifications.per_page
  json.page params[:page]
end
