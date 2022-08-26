json.status 'success'
json.data do
  json.clients do
    json.array! @clients do |client|
      json.id client.id
      json.name "#{client.first_name} #{client.last_name}"
    end  
  end
  json.staff do
    json.array! @staff do |staff|
      json.id staff.id
      json.name "#{staff.first_name} #{staff.last_name}"
      json.first_name staff.first_name
      json.last_name staff.last_name
      json.email staff.email
      json.status staff.status
      json.hired_at staff.hired_at
      json.terminated_on staff.terminated_on
      json.title staff.role_name
      json.gender staff.gender
      json.legacy_number staff.legacy_number
    end
  end
  json.services do
    json.array! @services do |service|
      json.id service.id
      json.name service.name
      json.display_code service.display_code
      json.is_early_code service&.is_early_code
      json.is_service_provider_required service.is_service_provider_required
    end
  end
end
