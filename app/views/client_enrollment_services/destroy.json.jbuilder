json.status 'success'
json.data do
  json.partial! 'client_enrollment_service_detail', enrollment_service: @enrollment_service
  json.service_providers do
    json.array! @enrollment_service.service_providers do |service_provider|
      json.id service_provider.staff_id
      json.name "#{service_provider.staff&.first_name} #{service_provider.staff&.last_name}"
    end 
  end
end
