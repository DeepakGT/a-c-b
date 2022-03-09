json.status 'success'
json.data do
  json.id @service.id
  json.name @service.name
  json.status @service.status
  json.display_code @service.display_code
  if @service.qualifications.present?
    json.qualification_ids @service.qualifications.pluck(:id)
    json.qualification_names @service.qualifications.pluck(:name)
  end
end
