json.status @role.errors.any? ? 'failure' : 'success'
json.data do
  json.partial! 'role_detail', role: @role
end
json.errors @role.errors.full_messages
