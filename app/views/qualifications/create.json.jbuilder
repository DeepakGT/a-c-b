json.status @qualification.errors.any? ? 'failure' : 'success'
json.data do
  json.id @qualification.id
end
json.errors @qualification.errors.full_messages
