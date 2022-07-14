json.status 'success'
json.data do
  json.array! @organizations do |organization|
    json.id organization.id
    json.name organization.name
    json.aka organization.aka
    json.web organization.web
    json.email organization.email
    json.status organization.status
    if organization.phone_number.present?
      json.phone_number do
        json.id organization.phone_number.id
        json.phone_type organization.phone_number.phone_type
        json.number organization.phone_number.number
      end
    end
    if organization.address.present?
      json.address do
        json.id organization.address.id
        json.line1 organization.address.line1
        json.line2 organization.address.line2
        json.line3 organization.address.line3
        json.zipcode organization.address.zipcode
        json.city organization.address.city
        json.state organization.address.state
        json.country organization.address.country
      end
    end
  end
end
if params[:page].present?
  json.total_records @organizations.total_entries
  json.limit @organizations.per_page
  json.page params[:page]
end
