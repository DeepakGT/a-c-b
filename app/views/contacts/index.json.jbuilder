json.status 'success'
json.data do
  json.array! @contacts do |contact|
    json.id contact.id
    json.first_name contact.first_name
    json.last_name contact.last_name
    json.email contact.email
    json.client_id contact.client_id
    json.type contact.relation_type
    json.relation contact.relation
    json.legal_guardian contact.legal_guardian
    json.guarantor contact.guarantor
    json.parent_portal_access contact.parent_portal_access
    json.resides_with_client contact.resides_with_client
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
    if contact.phone_numbers.present?
      json.phone_numbers do
        json.array! contact.phone_numbers do |phone_number|
          json.id phone_number.id
          json.phone_type phone_number.phone_type
          json.number phone_number.number
        end
      end
    end
  end
end
if params[:page].present?
  json.total_records @contacts.total_entries
  json.limit @contacts.per_page
  json.page params[:page]
end
