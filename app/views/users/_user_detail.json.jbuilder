json.id user.id
json.first_name user.first_name
json.last_name user.last_name
json.email user.email
json.status user.status
json.title user.role_name
json.gender user.gender
json.deactive_at user.deactive_at
json.is_email_notification_allowed user.allow_email_notifications?
json.default_schedule_view user.default_schedule_view
json.phone_numbers do
  json.array! user.phone_numbers.order(:id) do |phone|
    json.id phone.id
    json.phone_type phone.phone_type
    json.number phone.number
  end
end
if user.address.present?
  json.address do
    json.id user.address.id
    json.line1 user.address.line1
    json.line2 user.address.line2
    json.line3 user.address.line3
    json.zipcode user.address.zipcode
    json.city user.address.city
    json.state user.address.state
    json.country user.address.country
  end
end
