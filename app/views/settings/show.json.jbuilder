json.status 'success'
json.data do
  json.id @setting.id
  json.welcome_note @setting.welcome_note
end
