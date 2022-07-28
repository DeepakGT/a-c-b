json.status 'success'
json.data do
  json.array! @contacts do |contact|
    json.partial! 'contact_detail', contact: contact
  end
end
if params[:page].present?
  json.total_records @contacts.total_entries
  json.limit @contacts.per_page
  json.page params[:page]
end
