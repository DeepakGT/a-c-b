json.status @schedule.errors.any? ? 'failure' : 'success'
json.rendered_message 'Appointments have been created and rendered successfully.' if @schedules.present?
json.data do
  json.array! @schedules do |schedule|
    json.partial! 'scheduling_detail', schedule: @schedule
  end
end
json.errors @schedule.errors.full_messages
