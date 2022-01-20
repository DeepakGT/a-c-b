json.status 'success'
json.data do
  json.array! @clients do |client|
    json.id client.id
    json.first_name client.first_name
    json.last_name client.last_name
    json.email client.email
    json.dob client.dob
    json.gender client.gender
    json.payer_status client.payer_status
    json.status client.status
    if client.addresses.present?
      json.addresses do
        json.array! client.addresses do |address|
          json.id address.id
          json.type address.address_type
          json.line1 address.line1
          json.line2 address.line2
          json.line3 address.line3
          json.zipcode address.zipcode
          json.city address.city
          json.state address.state
          json.country address.country
        end
      end
    end
    if client.phone_number.present?
      json.phone_number do
        json.id client.phone_number.id
        json.phone_type client.phone_number.phone_type
        json.number client.phone_number.number
      end
    end
  end
end
json.total_records @clients.total_entries
json.limit @clients.per_page
json.page params[:page] || 1
