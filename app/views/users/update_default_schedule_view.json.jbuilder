json.status @user.errors.any? ? 'failure' : 'success'
json.data do
  json.partial! 'user_detail', user: @user
end
json.errors @user.errors.full_messages
