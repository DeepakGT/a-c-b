json.status 'success'
json.data do
  json.array! @super_admins do |super_admin|
    json.partial! 'super_admin_detail', super_admin: super_admin
  end
end
if params[:page].present?
  json.total_records @super_admins.total_entries
  json.limit @super_admins.per_page
  json.page params[:page]
end
