json.status 'success'
json.data do
  json.id @staff.id
  json.first_name @staff.first_name
  json.last_name @staff.last_name
  json.email @staff.email
  json.status @staff.status
  json.service_provider @staff.service_provider
  json.terminated_on @staff.terminated_on
  json.title @staff.role_name
  json.gender @staff.gender
  json.organization_id @staff.clinic.organization_id
  json.organization_name @staff.clinic.organization_name
  json.clinic_id @staff.clinic_id
  json.clinic_name @staff.clinic.name
  if @staff.supervisor.present?
    json.supervisor_id @staff.supervisor_id
    json.immediate_supervisor "#{@staff.supervisor.first_name} #{@staff.supervisor.last_name}"
  end
  json.phone_numbers do
    json.array! @staff.phone_numbers do |phone|
      json.id phone.id
      json.phone_type phone.phone_type
      json.number phone.number
    end
  end
  if @staff.address.present?
    json.address do
      json.id @staff.address.id
      json.line1 @staff.address.line1
      json.line2 @staff.address.line2
      json.line3 @staff.address.line3
      json.zipcode @staff.address.zipcode
      json.city @staff.address.city
      json.state @staff.address.state
      json.country @staff.address.country
    end
  end
  if @staff.rbt_supervision.present?
    json.rbt_supervision do
      json.id @staff.rbt_supervision.id
      json.status @staff.rbt_supervision.status
    end
  end
  json.services do
    json.array! @staff.services do |service|
      json.id service.id
      json.name service.name
      json.status service.status
      #json.default_pay_code service.default_pay_code
      #json.category service.category
      #json.display_pay_code service.display_pay_code
      #json.tracking_id service.tracking_id
      json.display_code service.display_code
    end
  end
end
