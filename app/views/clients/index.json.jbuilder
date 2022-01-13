json.status 'success'
json.data do
  json.array! @clients do |client|
    json.id client.id
    json.first_name client.first_name
    json.last_name client.last_name
    json.email client.email
    json.dob client.dob
    json.gender client.gender
    json.status client.status
    if client.contacts.present?
      json.contacts do
        json.array! client.contacts do |contact|
          json.id contact.id
          json.first_name contact.first_name
          json.last_name contact.last_name
          if contact.address.present?
            json.address do
              json.id contact.address.id
              json.line1 contact.address.line1
              json.line2 contact.address.line2
              json.line3 contact.address.line3
              json.zipcode contact.address.zipcode
              json.city contact.address.city
              json.state contact.address.state
              json.country contact.address.country
            end
          end
          if contact.phone_number.present?
            json.phone_number do
              json.id contact.phone_number.id
              json.phone_type contact.phone_number.phone_type
              json.number contact.phone_number.number
            end
          end
        end
      end
    end
  end
end
