if @organization.errors.any?
  json.status 'failure'
  json.errors @organization.errors.full_messages
else
  json.status 'success'
  json.data do
    json.id @organization.id
    json.name @organization.name
    json.aka @organization.aka
    json.web @organization.web
    json.email @organization.email
    json.status @organization.status
    json.phone_numbers do
      json.array! @organization.phone_numbers do |phone|
        json.id phone.id
        json.phone_type phone.phone_type
        json.number phone.number
      end
    end
    if @organization.address.present?
      json.address do
        json.id @organization.address.id
        json.line1 @organization.address.line1
        json.line2 @organization.address.line2
        json.line3 @organization.address.line3
        json.zipcode @organization.address.zipcode
        json.city @organization.address.city
        json.state @organization.address.state
        json.country @organization.address.country
      end
    end
  end
end
