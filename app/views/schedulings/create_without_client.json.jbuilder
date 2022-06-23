json.status @schedule.errors.any? ? 'failure' : 'success'
json.data do
  json.id @schedule.id
  json.status @schedule.status
  json.date @schedule.date
  json.start_time @schedule.start_time
  json.end_time @schedule.end_time
  json.non_billable_reason @schedule.non_billable_reason
end
json.errors @schedule.errors.full_messages
