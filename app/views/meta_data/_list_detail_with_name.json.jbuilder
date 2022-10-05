json.array! list do |data|
  json.id data&.id
  json.name "#{data&.name} (#{data&.display_code})"
  json.network_status data&.network_status if data.class.name.eql? 'FundingSource'
end
