json.status 'success'
json.data do
  json.array! @clinics do |clinic|
    json.partial! 'clinic_detail', clinic: clinic
  end
end
if params[:page].present?
  json.total_records @clinics.total_entries
  json.limit @clinics.per_page
  json.page params[:page]
end
