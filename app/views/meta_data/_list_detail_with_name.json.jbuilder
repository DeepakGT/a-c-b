json.array! list do |data|
  json.id data&.id
  json.name data&.name
  json.network_status data&.network_status
end
