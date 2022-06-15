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
  json.staff_id @schedule.staff_id
  json.staff_name "#{@schedule.staff.first_name} #{@schedule.staff.last_name}" if @schedule.staff.present?
  json.service_id service&.id
  json.service_name service&.name
  json.service_display_code service&.display_code 
  json.status @schedule.status
  json.date @schedule.date
  json.start_time @schedule.start_time
  json.end_time @schedule.end_time
  json.is_rendered @schedule.is_rendered
  json.unrendered_reasons @schedule.unrendered_reason
  json.rendered_at @schedule.rendered_at
  if @schedule.is_rendered==true
    json.rendered_message "Appointment has been created and rendered successfully."
  elsif @schedule.unrendered_reason.present?
    message = "Appointment has been updated but cannot be rendered because #{@schedule.unrendered_reason.to_human_string}"
    message.gsub!('absent', 'not found')
    message.gsub!('_',' ')
    json.rendered_message message
  end
  json.units @schedule.units
  json.minutes @schedule.minutes
  if @schedule.creator_id.present?
    creator = User.find_by(id: @schedule.creator_id)
    json.creator_id @schedule.creator_id
    json.creator_name "#{creator&.first_name} #{creator&.last_name}"
  else
    json.creator_id nil
    json.creator_name nil
  end
  if @schedule.updator_id.present?
    updator = User.find_by(id: @schedule.updator_id)
    json.updator_id @schedule.updator_id
    json.updator_name "#{updator&.first_name} #{updator&.last_name}"
  else
    json.updator_id nil
    json.updator_name nil
  end
end
json.errors @schedule.errors.full_messages
