json.status 'success'
json.data do
  json.partial! 'user_detail', user: @user
end
