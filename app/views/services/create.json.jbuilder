if @service.errors.any?
  json.status 'failure'
  json.errors @service.errors.full_messages
else
  json.status 'success'
  json.data do
    json.id @service.id
    json.name @service.name
    json.status @service.status
    json.display_code @service.display_code
  end
end
