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
  end
end
