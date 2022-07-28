json.status 'success'
json.data do
  json.array! @roles do |role|
    json.partial! 'role_detail', role: role
  end
end
if params[:page].present?
  json.total_records @roles.total_entries
  json.limit @roles.per_page
  json.page params[:page]
end
