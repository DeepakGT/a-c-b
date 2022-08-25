json.status 'success'
json.data do
  json.partial! 'scheduling_detail', schedule: @schedule
end
