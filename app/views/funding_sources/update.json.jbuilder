json.status @funding_source.errors.any? ? 'failure' : 'success'
json.data do
  json.id @funding_source.id
  json.name @funding_source.name
  json.title @funding_source.title
  json.status @funding_source.status
  json.clinic_id @funding_source.clinic_id
end
json.errors @funding_source.errors.full_messages
