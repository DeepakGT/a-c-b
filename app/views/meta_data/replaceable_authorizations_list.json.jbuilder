json.status 'success'
json.data do
  json.array! @authorizations do |authorization|
    json.id authorization.id
    json.funding_source_id authorization&.client_enrollment&.funding_source_id
    json.funding_source_name authorization&.client_enrollment&.funding_source&.name
    json.service_id authorization&.service&.id
    json.service_name authorization&.service&.name
  end
end
json.total_count @authorizations.count
