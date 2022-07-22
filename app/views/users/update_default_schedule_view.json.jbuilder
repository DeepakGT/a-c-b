json.status @user.errors.any? ? 'failure' : 'success'
json.data do
  json.id @user.id
  json.first_name @user.first_name
  json.last_name @user.last_name
  json.email @user.email
  json.status @user.status
  json.title @user.role_name
  json.gender @user.gender
  json.default_schedule_view @user.default_schedule_view
end
json.errors @user.errors.full_messages
