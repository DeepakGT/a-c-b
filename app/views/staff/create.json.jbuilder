json.status @staff.errors.any? ? 'failure' : 'success'
json.data do
  json.id @staff.id
  json.first_name @staff.first_name
  json.last_name @staff.last_name
  json.email @staff.email
  json.role @staff.role.name
  json.status @staff.status
  json.terminated_on @staff.terminated_on
  json.gender @staff.gender
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
end
json.errors @staff.errors.full_messages
