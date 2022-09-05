json.status @organization.errors.any? ? 'failure' : 'success'
json.data do
  json.partial! 'organization_detail', organization: @organization
end
json.errors @organization.errors.full_messages
