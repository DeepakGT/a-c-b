json.status 'success'
json.data do
  json.partial! 'scheduling_detail', schedule: @schedule.reload
end
json.errors @schedule.errors.full_messages
