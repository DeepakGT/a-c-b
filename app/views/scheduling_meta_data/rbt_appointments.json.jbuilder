json.status 'success'
json.data do
  json.upcoming_schedules do
    json.array! @upcoming_schedules do |schedule|
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
      json.units schedule.units
      json.minutes schedule.minutes
      if schedule.scheduling_change_requests.by_approval_status.any?
        json.request_raised 1
      end
    end
  end
  json.past_schedules do
    json.array! @past_schedules do |schedule|
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
      if schedule.date<(Time.now.to_date-1) || (schedule.date==(Time.now.to_date-1) && schedule.end_time<Time.now.strftime('%H:%M'))
        json.exceeded_24_h true
      else
        json.exceeded_24_h false
      end
      if schedule.date<(Time.now.to_date-3) || (schedule.date==(Time.now.to_date-3) && schedule.end_time<Time.now.strftime('%H:%M'))
        json.exceeded_3_days true
      else
        json.exceeded_3_days false
      end
      if schedule.date<(Time.now.to_date-5) || (schedule.date==(Time.now.to_date-5) && schedule.end_time<Time.now.strftime('%H:%M'))
        json.exceeded_5_days true
      else
        json.exceeded_5_days false
      end
      if schedule.catalyst_data_ids.present?
        catalyst_datas = CatalystData.where(id: schedule.catalyst_data_ids).where(system_scheduling_id: schedule.id)
        if catalyst_datas.present?
          json.catalyst_data do
            json.array! catalyst_datas do |catalyst_data|
              json.id catalyst_data.id
              json.client_name "#{catalyst_data.client_first_name} #{catalyst_data.client_last_name}"
              json.staff_name "#{catalyst_data.staff_first_name} #{catalyst_data.staff_last_name}"
              json.date "#{catalyst_data.date}"
              json.start_time "#{catalyst_data.start_time}"
              json.end_time "#{catalyst_data.end_time}"
              json.units "#{catalyst_data.units}"
              json.minutes "#{catalyst_data.minutes}"
              json.note catalyst_data.note
            end
          end
        end
      end
      if !(schedule.unrendered_reason.include?('units_does_not_match')) && !(schedule.unrendered_reason.include?('soap_note_absent'))
        json.soap_note_id schedule.soap_notes.last.id if schedule.soap_notes.present?
        json.synced_with_catalyst schedule.soap_notes.last.synced_with_catalyst if schedule.soap_notes.present?
      end
    end
  end
  json.no_appointment_catalyst_data do
    json.array! @catalyst_data do |catalyst_data|
      json.id catalyst_data.id
      json.client_name "#{catalyst_data.client_first_name} #{catalyst_data.client_last_name}"
      json.client_id Client.find_by(first_name: catalyst_data.client_first_name, last_name: catalyst_data.client_last_name)&.id
      json.staff_name "#{catalyst_data.staff_first_name} #{catalyst_data.staff_last_name}"
      json.staff_id Staff.find_by(first_name: catalyst_data.staff_first_name, last_name: catalyst_data.staff_last_name)&.id
      json.date "#{catalyst_data.date}"
      json.start_time "#{catalyst_data.start_time}"
      json.end_time "#{catalyst_data.end_time}"
      json.units "#{catalyst_data.units}"
      json.minutes "#{catalyst_data.minutes}"
      json.note catalyst_data.note
    end
  end
  json.multiple_catalyst_notes do
    json.array! @multiple_catalyst_notes do |catalyst_data|
      json.id catalyst_data.id
      json.client_name "#{catalyst_data.client_first_name} #{catalyst_data.client_last_name}"
      json.staff_name "#{catalyst_data.staff_first_name} #{catalyst_data.staff_last_name}"
      json.date "#{catalyst_data.date}"
      json.start_time "#{catalyst_data.start_time}"
      json.end_time "#{catalyst_data.end_time}"
      json.units "#{catalyst_data.units}"
      json.minutes "#{catalyst_data.minutes}"
      json.note catalyst_data.note
    end
  end
end
