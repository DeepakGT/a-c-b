json.status 'success'
json.data do
  json.partial! 'organization_detail', organization: @organization
end
