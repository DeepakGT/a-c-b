if @staff.errors.any?
  json.status 'failure'
  json.errors @staff.errors.full_messages
else
  json.status 'success'
  json.data do
    json.id @staff.id
    json.first_name @staff.first_name
    json.last_name @staff.last_name
    json.email @staff.email
    json.status @staff.status
    json.terminated_on @staff.terminated_on
    json.gender @staff.gender
    json.supervisor_id @staff.supervisor_id
  end
end
