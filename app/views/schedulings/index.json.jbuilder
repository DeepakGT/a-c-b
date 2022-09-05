json.status 'success'
json.data do
  json.array! @schedules do |schedule|
    client = schedule.client_enrollment_service&.client_enrollment&.client
    service = schedule.client_enrollment_service&.service
    staff = schedule&.staff
    json.id schedule.id
    json.cross_site_allowed schedule.cross_site_allowed
    json.appointment_office_id schedule&.appointment_office_id
    json.appointment_office Clinic.find_by(id: schedule&.appointment_office_id)&.name
    # # json.client_id client&.id
    json.client_name "#{client.first_name} #{client.last_name}" if client.present?
    if schedule.service_address_id.present?
      service_address = Address.find_by(id: schedule.service_address_id)
      if service_address.present?
        json.service_address do
          json.service_address_line1 service_address.line1
          json.service_address_line2 service_address.line2
          json.service_address_line3 service_address.line3
          json.service_address_zipcode service_address.zipcode
          json.service_address_city service_address.city
          json.service_address_state service_address.state
          json.service_address_country service_address.country
          json.service_address_is_default service_address.is_default
          json.service_address_type_id service_address.service_address_type_id if service_address.service_address_type_id.present?
          json.service_address_type_name service_address.service_address_type_name if service_address.service_address_type_id.present?
        end
      end
    end
    json.staff_name "#{staff.first_name} #{staff.last_name}" if staff.present?
    json.service_name service&.name
    json.service_display_code service&.display_code 
    json.is_early_code service&.is_early_code
    json.status schedule.status
    json.date schedule.date
    json.start_time schedule.start_time&.in_time_zone&.strftime("%I:%M %p")
    json.end_time schedule.end_time&.in_time_zone&.strftime("%I:%M %p")
    # json.is_rendered schedule.is_rendered
    if schedule.rendered_at.present? && schedule.status == 'rendered'
      json.is_rendered true
    else
      json.is_rendered false
    end
    json.unrendered_reasons schedule.unrendered_reason
    json.rendered_at schedule.rendered_at
    json.units schedule.units
    json.minutes schedule.minutes
  end
end
json.show_inactive params[:show_inactive] if (params[:show_inactive] == 1 || params[:show_inactive] == "1")
json.partial! '/pagination_detail', list: @schedules, page_number: params[:page]
