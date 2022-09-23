json.status @schedule.errors.any? ? 'failure' : 'success'
json.data do
  json.partial! 'scheduling_without_client', schedule: @schedule
end
json.errors @schedule.errors.full_messages
