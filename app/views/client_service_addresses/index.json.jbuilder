json.status 'success'
json.data do
  json.array! @service_addresses do |address|
    json.partial! 'service_address_detail', service_address: address
    if Scheduling.where(service_address_id: address.id).blank?
      json.associated_with_appointment false
    else
      json.associated_with_appointment true
    end
  end
end
if @service_addresses.where(line1: @client.clinic.address&.line1).present?
  json.office_address true
else
  json.office_address false
end

