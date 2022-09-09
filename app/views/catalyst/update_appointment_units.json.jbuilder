json.status @schedule.errors.any? ? 'failure' : 'success'
json.data do
  json.partial! 'scheduling_detail', schedule: @schedule
end
json.errors @schedule.errors.full_messages
