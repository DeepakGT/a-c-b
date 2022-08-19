json.status 'success'
json.data do
  json.partial! 'scheduling_detail', schedule: @schedule.reload
  if @schedule.rendered_at.present?
    json.rendered_message "Appointment has been updated and rendered successfully."
  elsif @schedule.unrendered_reason.present?
    message = "Appointment has been updated but cannot be rendered because #{@schedule.unrendered_reason.to_human_string}"
    message.gsub!('absent', 'not found')
    message.gsub!('_',' ')
    json.rendered_message message
  end
end
json.errors @schedule.errors.full_messages
