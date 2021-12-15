json.status 'success'
json.data do
  json.array! @credentials do |credential|
    json.id credential.id
    json.type credential.credential_type
    json.name credential.name
    json.description credential.description
    json.lifetime credential.lifetime
  end
end
if params[:page].present?
  json.total_records @credentials.total_entries
  json.limit @credentials.per_page
  json.page params[:page]
end
