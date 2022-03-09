json.status 'success'
json.data do
  json.array! @services do |service|
    json.id service.id
    json.name service.name
    json.status service.status
    json.display_code service.display_code
    if service.qualifications.present?
      json.qualification_ids service.qualifications.pluck(:id)
      json.qualification_names service.qualifications.pluck(:name)
    end
  end
end
json.total_records @services.total_entries
json.limit @services.per_page
json.page params[:page] || 1
