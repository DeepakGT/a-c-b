json.status 'success'
json.data do
  json.array! @organizations do |organization|
    json.partial! 'organization_detail', organization: organization
  end
end
json.partial! '/pagination_detail', list: @organizations, page_number: params[:page]
