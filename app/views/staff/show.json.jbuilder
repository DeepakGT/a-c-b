json.status 'success'
json.data do
  json.id @staff.id
  json.first_name @staff.first_name
  json.last_name @staff.last_name
  json.email @staff.email
  json.web_address @staff.web_address
  json.status @staff.status
  json.pay_type @staff.pay_type
  json.hired_at @staff.hired_at
  json.service_provider @staff.service_provider
  json.timing_type json.timing_type
  json.hours_per_week @staff.hours_per_week
  json.terminated_at @staff.terminated_at
  json.residency @staff.residency
  json.status_date @staff.status_date
  json.driving_license @staff.driving_license
  json.driving_license_expires_at @staff.driving_license_expires_at
  json.title @staff.role_name
  json.gender @staff.gender
  json.department @staff.user_role.department
  json.date_of_birth @staff.date_of_birth
  json.ssn @staff.ssn
  json.badge_id @staff.badge_id
  json.badge_type @staff.badge_type
  json.supervisor_id @staff.supervisor_id
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
      json.default_pay_code service.default_pay_code
      json.category service.category
      json.display_pay_code service.display_pay_code
      json.tracking_id service.tracking_id
    end
  end
end
