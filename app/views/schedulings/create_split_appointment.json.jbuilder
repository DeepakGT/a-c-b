json.status 'success'
json.rendered_message 'Appointments have been created and rendered successfully.'
json.data do
  json.array! @schedules do |schedule|
    client = schedule.client_enrollment_service&.client_enrollment&.client
    service = schedule.client_enrollment_service&.service
    staff = schedule&.staff
    # schedules = Scheduling.by_client_and_service(schedule.client_enrollment_service.client_enrollment.client_id, schedule.client_enrollment_service.service_id)
    # schedules = schedules.with_rendered_or_scheduled_as_status
    # completed_schedules = schedules.completed_scheduling
    # scheduled_schedules = schedules.scheduled_scheduling
    # used_units = completed_schedules.with_units.pluck(:units).sum
    # scheduled_units = scheduled_schedules.with_units.pluck(:units).sum
    # used_minutes = completed_schedules.with_minutes.pluck(:minutes).sum
    # scheduled_minutes = scheduled_schedules.with_minutes.pluck(:minutes).sum
    json.id schedule.id
    # # json.client_enrollment_service_id schedule.client_enrollment_service_id
    # # json.total_units schedule.client_enrollment_service.units
    # # json.used_units schedule.client_enrollment_service&.used_units
    # # json.scheduled_units schedule.client_enrollment_service&.scheduled_units
    # # json.left_units schedule.client_enrollment_service.left_units
    # if schedule.client_enrollment_service.units.present?
    #   json.left_units schedule.client_enrollment_service.units - (used_units + scheduled_units) 
    # else
    #   json.left_units 0
    # end
    # # json.total_minutes schedule.client_enrollment_service.minutes
    # # json.used_minutes schedule.client_enrollment_service&.used_minutes
    # # json.scheduled_minutes schedule.client_enrollment_service&.scheduled_minutes
    # # json.left_minutes schedule.client_enrollment_service.left_minutes
    # if schedule.client_enrollment_service.minutes.present?
    #   json.left_minutes schedule.client_enrollment_service.minutes - (used_minutes + scheduled_minutes)
    # else
    #   json.left_minutes 0
    # end
    json.cross_site_allowed schedule.cross_site_allowed
    # # json.client_id client&.id
    json.client_name "#{client.first_name} #{client.last_name}" if client.present?
    # # json.service_address_id schedule.service_address_id
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
          json.service_address_address_name service_address.address_name
        end
        end
        # # json.staff_id schedule.staff_id
        json.staff_name "#{staff.first_name} #{staff.last_name}" if staff.present?
        # # json.service_id service&.id
        json.service_name service&.name
        json.service_display_code service&.display_code 
        json.status schedule.status
        json.date schedule.date
        json.start_time schedule.start_time.in_time_zone.strftime("%I:%M %p")
        json.end_time schedule.end_time.in_time_zone.strftime("%I:%M %p")
        # json.is_rendered schedule.is_rendered
        if schedule.rendered_at.present?
        json.is_rendered true
        else
        json.is_rendered false
        end
        json.unrendered_reasons schedule.unrendered_reason
        json.rendered_at schedule.rendered_at
        json.units schedule.units
        json.minutes schedule.minutes
        # if schedule.creator_id.present?
        #   creator = User.find(schedule.creator_id)
        #   json.creator_id schedule.creator_id
        #   json.creator_name "#{creator&.first_name} #{creator&.last_name}"
        # else
        #   json.creator_id nil
        #   json.creator_name nil
        # end
        # if schedule.updator_id.present?
        #   updator = User.find(schedule.updator_id)
        #   json.updator_id schedule.updator_id
        #   json.updator_name "#{updator&.first_name} #{updator&.last_name}"
        # else
        #   json.updator_id nil
        #   json.updator_name nil
        # end
    end
    json.unrendered_reasons schedule.unrendered_reason
    json.rendered_at schedule.rendered_at
    json.units schedule.units
    json.minutes schedule.minutes
    # if schedule.creator_id.present?
    #   creator = User.find(schedule.creator_id)
    #   json.creator_id schedule.creator_id
    #   json.creator_name "#{creator&.first_name} #{creator&.last_name}"
    # else
    #   json.creator_id nil
    #   json.creator_name nil
    # end
    # if schedule.updator_id.present?
    #   updator = User.find(schedule.updator_id)
    #   json.updator_id schedule.updator_id
    #   json.updator_name "#{updator&.first_name} #{updator&.last_name}"
    # else
    #   json.updator_id nil
    #   json.updator_name nil
    # end
  end
end
