json.status @office_address.errors.any? ? 'failure' : 'success'
json.data do
  json.partial! 'service_address_detail', service_address: @office_address
end
json.errors @office_address.errors.full_messages&.map{|x| x.gsub('Address ', '')}
