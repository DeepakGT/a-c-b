json.status 'success'
json.data do
  json.array! @roles do |role|
    json.partial! 'role_detail', role: role
  end
end
json.partial! 'pagination_detail', list: @roles, page_number: params[:page]
