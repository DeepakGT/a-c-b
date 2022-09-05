json.status 'success'
json.data do
  json.clients do
    json.array! @clients do |client|
      json.partial! 'client_detail', client: client
    end  
  end
  json.staff do
    json.array! @staff do |staff|
      json.partial! 'staff_detail', staff: staff
    end
  end
  json.services do
    json.array! @services do |service|
      json.partial! 'services/service_detail', service: service
    end
  end
end
