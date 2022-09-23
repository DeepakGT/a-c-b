json.status @soap_note.errors.any? ? 'failure' : 'success'
json.data do
  json.partial! 'soap_note_detail', soap_note: @soap_note
  if @soap_note.scheduling.reload.rendered_at.present?
    json.rendered_message "Soap note has been created and Appointment has been rendered successfully."
  elsif @soap_note.scheduling.unrendered_reason.present?
    message = "Appointment has been updated but cannot be rendered because #{@soap_note.scheduling.unrendered_reason.to_human_string}"
    message.gsub!('absent', 'not found')
    message.gsub!('_',' ')
    json.rendered_message message
  end
end
json.errors @soap_note.errors.full_messages
