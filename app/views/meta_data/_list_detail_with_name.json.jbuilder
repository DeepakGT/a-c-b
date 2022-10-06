json.array! list do |data|
  json.id data&.id
  json.name data.class.name == 'Service' ? "#{data&.name} (#{data&.display_code})" : data&.name
  json.network_status data&.network_status if data.class.name.eql? 'FundingSource'
end
