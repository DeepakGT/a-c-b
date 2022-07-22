json.status @schedule.errors.any? ? 'failure' : 'success'
json.data do
  client = @schedule.client_enrollment_service&.client_enrollment&.client
  service = @schedule.client_enrollment_service&.service
  json.id @schedule.id
  json.client_enrollment_service_id @schedule.client_enrollment_service_id
  json.cross_site_allowed @schedule.cross_site_allowed
  json.client_id client&.id
  json.client_name "#{client.first_name} #{client.last_name}" if client.present?
  json.service_address_id @schedule.service_address_id
  if @schedule.service_address_id.present?
    service_address = Address.find_by(id: @schedule.service_address_id)
    if service_address.present?
      json.service_address do
        json.line1 service_address.line1
        json.line2 service_address.line2
        json.line3 service_address.line3
        json.zipcode service_address.zipcode
        json.city service_address.city
        json.state service_address.state
        json.country service_address.country
        json.is_default service_address.is_default
        json.address_name service_address.address_name
      end
    end
  end
  json.service_id service&.id
  json.service_name service&.name
  json.service_display_code service&.display_code 
  json.is_early_code service&.is_early_code
  json.status @schedule.status
  json.date @schedule.date
  json.start_time @schedule.start_time.in_time_zone.strftime("%I:%M %p")
  json.end_time @schedule.end_time.in_time_zone.strftime("%I:%M %p")
  # json.is_rendered @schedule.is_rendered
  if @schedule.rendered_at.present? && @schedule.status == 'Rendered'
    json.is_rendered true
  else
    json.is_rendered false
  end
  json.unrendered_reasons @schedule.unrendered_reason
  json.rendered_at @schedule.rendered_at
  json.units @schedule.units
  json.minutes @schedule.minutes
end
json.errors @schedule.errors.full_messages
