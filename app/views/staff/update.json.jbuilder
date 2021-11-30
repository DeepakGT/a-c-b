if @staff.present?
  json.status @staff.errors.any? ? 'failure' : 'success'
  json.data do
    json.id @staff.id
  end
  json.errors @staff.errors.full_messages
else
  json.status 'failure'
  json.errors ['staff not found.']
end
