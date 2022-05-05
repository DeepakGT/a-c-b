json.status @setting.errors.any? ? 'failure' : 'success'
json.data do
  json.id @setting.id
  json.welcome_note @setting.welcome_note
end
json.errors @setting.errors.full_messages
