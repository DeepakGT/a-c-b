json.status 'success'
json.data do
  json.partial! 'role_detail', role: @role
end
