json.status 'success'
json.data do
  json.array! @supervisors do |supervisor|
    json.id supervisor.id
    json.first_name supervisor.first_name
    json.last_name supervisor.last_name
  end
end
