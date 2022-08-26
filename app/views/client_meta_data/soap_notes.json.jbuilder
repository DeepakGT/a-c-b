json.status 'success'
json.data do
  json.array! @soap_notes do |soap_note|
    json.partial! 'soap_note_detail', soap_note: soap_note
  end
end
if params[:page].present?
  json.total_records @soap_notes.total_entries
  json.limit @soap_notes.per_page
  json.page params[:page]
end
