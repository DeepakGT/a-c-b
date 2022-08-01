json.status 'success'
json.data do
  json.array! @client_enrollments do |client_enrollment|
    json.id client_enrollment.funding_source&.id
    json.name client_enrollment.funding_source&.name
  end
end
