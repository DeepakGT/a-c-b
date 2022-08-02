json.status 'success'
json.data do
  json.array! @super_admins do |super_admin|
    json.partial! 'super_admin_detail', super_admin: super_admin
  end
end
json.partial! 'pagination_detail', list: @super_admins, page_number: params[:page]
