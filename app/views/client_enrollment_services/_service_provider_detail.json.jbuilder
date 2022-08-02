if object_type=='arrays'
  json.service_providers do
    json.ids enrollment_service&.service_providers&.pluck(:staff_id)
    json.names enrollment_service.staff&.map{|staff| "#{staff&.first_name} #{staff&.last_name}"}
    json.staff_ids enrollment_service&.service_providers&.pluck(:staff_id)
  end
else
  json.service_providers do
    json.array! @enrollment_service.service_providers do |service_provider|
      json.id service_provider.staff_id
      json.name "#{service_provider.staff&.first_name} #{service_provider.staff&.last_name}"
    end 
  end
end
