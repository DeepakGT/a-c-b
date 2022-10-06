json.status @change_request.reload.errors.any? ? 'failure' : 'success'
json.data do
  json.partial! 'scheduling_change_request_detail', change_request: @change_request
end
json.errors @change_request.errors.full_messages
