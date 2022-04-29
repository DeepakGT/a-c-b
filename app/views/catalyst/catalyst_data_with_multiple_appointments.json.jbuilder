json.status 'success'
json.data do
  staff = Staff.find_by(catalyst_user_id: catalyst_data.catalyst_user_id)
  client = Client.find_by(catalyst_patient_id: catalyst_data.catalyst_patient_id)
  json.id @catalyst_data.id
  json.client_name "#{client&.first_name} #{client&.last_name}"
  json.client_id client&.id
  json.staff_name "#{staff&.first_name} #{staff&.last_name}"
  json.staff_id staff&.id
  json.date "#{@catalyst_data.date}"
  json.start_time "#{@catalyst_data.start_time}"
  json.end_time "#{@catalyst_data.end_time}"
  json.units "#{@catalyst_data.units}"
  json.minutes "#{@catalyst_data.minutes}"
  json.note @catalyst_data.note
  json.appointments do
    json.array! @schedules do |schedule|
      client = schedule.client_enrollment_service&.client_enrollment&.client
      service = schedule.client_enrollment_service&.service
      json.id schedule.id
      json.client_enrollment_service_id schedule.client_enrollment_service_id
      json.cross_site_allowed schedule.cross_site_allowed
      json.client_id client&.id
      json.client_name "#{client.first_name} #{client.last_name}" if client.present?
      json.service_address_id schedule.service_address_id
      if schedule.service_address_id.present?
        service_address = Address.find(schedule.service_address_id)
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
      json.staff_id schedule.staff_id
      json.staff_name "#{schedule.staff.first_name} #{schedule.staff.last_name}" if schedule.staff.present?
      json.staff_role schedule.staff.role_name if schedule.staff.present?
      json.service_id service&.id
      json.service_name service&.name
      json.service_display_code service&.display_code 
      json.status schedule.status
      json.date schedule.date
      json.start_time schedule.start_time
      json.end_time schedule.end_time
      json.is_rendered schedule.is_rendered
      json.unrendered_reasons schedule.unrendered_reason
      json.units schedule.units
      json.minutes schedule.minutes
    end
  end
end
