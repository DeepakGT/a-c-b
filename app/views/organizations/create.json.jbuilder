if @organization.errors.any?
  json.status 'failure'
  json.errors @organization.errors.full_messages&.map{|x| x.gsub('Address ', '')}
else
  json.status 'success'
  json.data do
    json.partial! 'organization_detail', organization: @organization
  end
end
