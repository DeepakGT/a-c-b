json.status 'success'
json.data do
  json.partial! 'client_enrollment_service_detail', enrollment_service: @enrollment_service
  json.service_providers do
    json.ids @enrollment_service.service_providers.pluck(:id)
    json.staff_ids @enrollment_service.service_providers.pluck(:staff_id)
    json.names @enrollment_service.staff&.map{|staff| "#{staff.first_name} #{staff.last_name}"}
  end
end
