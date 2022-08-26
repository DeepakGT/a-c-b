json.status @super_admin.errors.any? ? 'failure' : 'success'
json.data do
  json.partial! 'super_admin_detail', super_admin: @super_admin
end
json.errors @super_admin.errors.full_messages
