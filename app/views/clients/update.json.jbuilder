json.status @client.errors.any? ? 'failure' : 'success'
json.data do
  json.id @client.id
  json.first_name @client.first_name
  json.last_name @client.last_name
  json.email @client.email
  json.dob @client.dob
  json.gender @client.gender
  json.status @client.status
end
json.errors @client.errors.full_messages
