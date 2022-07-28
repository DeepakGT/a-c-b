json.status 'success'
json.data do
  json.array! @organizations do |organization|
    json.partial! 'organization_detail', organization: organization
  end
end
if params[:page].present?
  json.total_records @organizations.total_entries
  json.limit @organizations.per_page
  json.page params[:page]
end
