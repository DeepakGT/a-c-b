json.status 'success'
json.data do
  json.array! @unassinged_notes do |unassinged_note|
    json.id unassinged_note.id
    json.note unassinged_note.note
    json.catalyst_soap_note_id unassinged_note.catalyst_soap_note_id
    json.date unassinged_note.date
    json.start_time unassinged_note.start_time
    json.end_time unassinged_note.end_time
    json.units unassinged_note.units
    json.minutes unassinged_note.minutes
    json.date_revision_made unassinged_note.date_revision_made
  end
end