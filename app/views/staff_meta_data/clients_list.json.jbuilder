json.status 'success'
json.data do
  json.array! @clients do |client|
    json.id client.id
    json.name "#{client.first_name} #{client.last_name}"
  end  
end
