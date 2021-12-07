json.status 'success'
json.data do
  json.array! @services do |service|
    json.id service.id
    json.name service.name
    json.display_code service.display_code
    json.category service.category
    json.default_pay_code service.default_pay_code
  end
end
