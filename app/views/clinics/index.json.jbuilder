json.status 'success'
json.data do
  json.array! @clinics do |clinic|
    json.id clinic.id
    json.name clinic.name
  end
end
json.total_records @clinics.total_entries
json.limit @clinics.per_page
json.page params[:page] || 1
