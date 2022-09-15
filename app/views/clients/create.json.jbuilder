json.status @client.errors.any? ? 'failure' : 'success'
json.data do
  json.id @client.id
  json.first_name @client.first_name
  json.last_name @client.last_name
  json.primary_bcba_id @client.primary_bcba_id
  json.secondary_bcba_id @client.secondary_bcba_id
  json.primary_rbt_id @client.primary_rbt_id
  json.secondary_rbt_id @client.secondary_rbt_id
  primary_bcba = User.find(@client.primary_bcba_id)
  json.primary_bcba_name "#{primary_bcba&.first_name} #{primary_bcba&.last_name}"
  secondary_bcba = User.find(@client.secondary_bcba_id)
  json.secondary_bcba_name "#{secondary_bcba&.first_name} #{secondary_bcba&.last_name}"
  primary_rbt = User.find(@client.primary_rbt_id)
  json.primary_rbt_name "#{primary_rbt&.first_name} #{primary_rbt&.last_name}"
  secondary_rbt = User.find(@client.secondary_rbt_id)
  json.secondary_rbt_name "#{secondary_rbt&.first_name} #{secondary_rbt&.last_name}"
  json.email @client.email
  json.dob @client.dob
  json.gender @client.gender
  json.status @client.status
  json.tracking_id @client.tracking_id
  json.preferred_language @client.preferred_language
  json.disqualified @client.disqualified
  json.disqualified_reason @client.dq_reason if @client.disqualified?
  if @client.addresses.present?
    json.addresses do
      json.array! @client.addresses do |address|
        json.id address.id
        json.type address.address_type
        json.line1 address.line1
        json.line2 address.line2
        json.line3 address.line3
        json.zipcode address.zipcode
        json.city address.city
        json.state address.state
        json.country address.country
        if address.address_type=='service_address'
          json.is_default address.is_default 
          json.is_hidden address.is_hidden
        end
      end
    end
  end
  if @client.phone_number.present?
    json.phone_number do
      json.id @client.phone_number.id
      json.phone_type @client.phone_number.phone_type
      json.number @client.phone_number.number
    end
  end
end
json.errors @client.errors.full_messages&.map{|x| x.gsub!('Address ', '')}
