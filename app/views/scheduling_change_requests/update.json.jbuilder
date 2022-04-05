json.status @change_request.reload.errors.any? ? 'failure' : 'success'
json.data do
  json.id @change_request.id
  json.date @change_request.date
  json.start_time @change_request.start_time
  json.end_time @change_request.end_time
  json.status @change_request.status
  json.approval_status @change_request.approval_status
  json.scheduling_id @change_request.scheduling_id
  json.scheduling_date @change_request.scheduling.date
  json.scheduling_start_time @change_request.scheduling.start_time
  json.scheduling_end_time @change_request.scheduling.end_time
  json.scheduling_status @change_request.scheduling.status
end
json.errors @change_request.errors.full_messages
