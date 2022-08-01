json.status 'success'
json.data do
  json.clients do
    json.array! @selectable_options[:clients] do |client|
      json.id client.id
      json.name "#{client.first_name} #{client.last_name}"
    end
  end
  json.staff do
    json.array! @selectable_options[:staff] do |staff|
      json.id staff.id
      json.name "#{staff.first_name} #{staff.last_name}"
    end
  end
  json.services do
    json.array! @selectable_options[:services] do |service|
      json.id service.id
      json.name service.name
      json.display_code service.display_code
      json.is_early_code service&.is_early_code
      json.is_service_provider_required service.is_service_provider_required
    end
  end
end
