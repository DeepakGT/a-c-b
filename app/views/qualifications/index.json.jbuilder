json.status 'success'
json.data do
  json.array! @qualifications do |qualification|
    json.partial! 'qualification_detail', qualification: qualification
  end
end
if params[:page].present?
  json.total_records @qualifications.total_entries
  json.limit @qualifications.per_page
  json.page params[:page]
end
