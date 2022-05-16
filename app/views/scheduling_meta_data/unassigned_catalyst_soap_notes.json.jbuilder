json.status 'success'
json.data do
  json.array! @unassigned_notes do |unassigned_note|
    staff = Staff.find_by(catalyst_user_id: unassigned_note.catalyst_user_id)
    json.id unassigned_note.id
    json.note unassigned_note.note
    json.catalyst_soap_note_id unassigned_note.catalyst_soap_note_id
    json.date unassigned_note.date
    json.start_time unassigned_note.start_time
    json.end_time unassigned_note.end_time
    json.units unassigned_note.units
    json.minutes unassigned_note.minutes
    json.date_revision_made unassigned_note.date_revision_made
    json.creator "#{staff&.first_name} #{staff&.last_name}"
  end
end