if @service.errors.any?
  json.status 'failure'
  json.errors @service.errors.full_messages
else
  json.status 'success'
  json.data do
    json.id @service.id
    json.name @service.name
    json.status @service.status
    json.default_pay_code @service.default_pay_code
    json.category @service.category
    json.display_code @service.display_code
    json.tracking_id @service.tracking_id
  end
end
