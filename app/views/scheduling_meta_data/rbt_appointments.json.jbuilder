json.status 'success'
json.data do
  json.setting_data Setting.first&.welcome_note

  # json.upcoming_schedules do
  #   json.array! @appointments do |appointment|
  #     if appointment.last=='Upcoming Schedule'
  #       schedule = Scheduling.find(appointment.first)
  #       client = schedule.client_enrollment_service&.client_enrollment&.client
  #       service = schedule.client_enrollment_service&.service
  #       json.id schedule.id
  #       json.client_enrollment_service_id schedule.client_enrollment_service_id
  #       json.cross_site_allowed schedule.cross_site_allowed
  #       json.client_id client&.id
  #       json.client_name "#{client.first_name} #{client.last_name}" if client.present?
  #       json.service_address_id schedule.service_address_id
  #       if schedule.service_address_id.present?
  #         service_address = Address.find(schedule.service_address_id)
  #         json.service_address do
  #           json.line1 service_address.line1
  #           json.line2 service_address.line2
  #           json.line3 service_address.line3
  #           json.zipcode service_address.zipcode
  #           json.city service_address.city
  #           json.state service_address.state
  #           json.country service_address.country
  #           json.is_default service_address.is_default
  #           json.address_name service_address.address_name
  #         end
  #       end
  #       json.staff_id schedule.staff_id
  #       json.staff_name "#{schedule.staff.first_name} #{schedule.staff.last_name}" if schedule.staff.present?
  #       json.staff_role schedule.staff.role_name if schedule.staff.present?
  #       json.service_id service&.id
  #       json.service_name service&.name
  #       json.service_display_code service&.display_code 
  #       json.status schedule.status
  #       json.date schedule.date
  #       json.start_time schedule.start_time
  #       json.end_time schedule.end_time
  #       json.is_rendered schedule.is_rendered
  #       json.units schedule.units
  #       json.minutes schedule.minutes
  #       if schedule.scheduling_change_requests.by_approval_status.any?
  #         json.request_raised 1
  #       end
  #     end
  #   end
  # end
  # exceeded_24_h = false
  # exceeded_3_days = false
  # exceeded_5_days = false
  # json.action_items do
  #   json.array! @appointments do |appointment|
  #     if appointment.last=='Past Schedule'
  #       schedule = Scheduling.find(appointment.first)
  #       client = schedule&.client_enrollment_service&.client_enrollment&.client
  #       service = schedule&.client_enrollment_service&.service
  #       json.id schedule&.id
  #       json.client_enrollment_service_id schedule&.client_enrollment_service_id
  #       json.cross_site_allowed schedule&.cross_site_allowed
  #       json.client_id client&.id
  #       json.client_name "#{client.first_name} #{client.last_name}" if client.present?
  #       json.service_address_id schedule&.service_address_id
  #       if schedule&.service_address_id.present?
  #         service_address = Address.find(schedule&.service_address_id)
  #         json.service_address do
  #           json.line1 service_address.line1
  #           json.line2 service_address.line2
  #           json.line3 service_address.line3
  #           json.zipcode service_address.zipcode
  #           json.city service_address.city
  #           json.state service_address.state
  #           json.country service_address.country
  #           json.is_default service_address.is_default
  #           json.address_name service_address.address_name
  #         end
  #       end
  #       json.staff_id schedule&.staff_id
  #       json.staff_name "#{schedule&.staff.first_name} #{schedule&.staff.last_name}" if schedule&.staff.present?
  #       json.staff_role schedule&.staff.role_name if schedule&.staff.present?
  #       json.service_id service&.id
  #       json.service_name service&.name
  #       json.service_display_code service&.display_code 
  #       json.status schedule&.status
  #       json.date schedule&.date
  #       json.start_time schedule&.start_time
  #       json.end_time schedule&.end_time
  #       json.is_rendered schedule&.is_rendered
  #       json.rendered_at schedule&.rendered_at
  #       json.unrendered_reasons schedule&.unrendered_reason
  #       json.units schedule&.units
  #       json.minutes schedule&.minutes
  #       if schedule&.catalyst_data_ids.present?
  #         catalyst_datas = CatalystData.where(id: schedule&.catalyst_data_ids).where(system_scheduling_id: schedule&.id)
  #         if catalyst_datas.present?
  #           json.catalyst_data do
  #             json.array! catalyst_datas do |catalyst_data|
  #               staff = Staff.find_by(catalyst_user_id: catalyst_data.catalyst_user_id)
  #               client = Client.find_by(catalyst_patient_id: catalyst_data.catalyst_patient_id)
  #               json.id catalyst_data.id
  #               json.client_name "#{client&.first_name} #{client&.last_name}"
  #               json.staff_name "#{staff&.first_name} #{staff&.last_name}"
  #               json.date "#{catalyst_data.date}"
  #               json.start_time "#{catalyst_data.start_time}"
  #               json.end_time "#{catalyst_data.end_time}"
  #               json.units "#{catalyst_data.units}"
  #               json.minutes "#{catalyst_data.minutes}"
  #               json.note catalyst_data.note
  #             end
  #           end
  #         end
  #       end
  #       if !(schedule&.unrendered_reason.include?('units_does_not_match')) && !(schedule&.unrendered_reason.include?('soap_note_absent'))
  #         json.soap_note_id schedule&.soap_notes.last.id if schedule&.soap_notes.present?
  #         json.synced_with_catalyst schedule&.soap_notes.last.synced_with_catalyst if schedule&.soap_notes.present?
  #       end
  #       if schedule.date<(Time.current.to_date-1) || (schedule.date==(Time.current.to_date-1) && schedule.end_time<Time.current.strftime('%H:%M'))
  #         exceeded_24_h = true
  #       elsif schedule.date<(Time.current.to_date-3) || (schedule.date==(Time.current.to_date-3) && schedule.end_time<Time.current.strftime('%H:%M'))
  #         exceeded_3_days = true
  #       elsif schedule.date<(Time.current.to_date-5) || (schedule.date==(Time.current.to_date-5) && schedule.end_time<Time.current.strftime('%H:%M'))
  #         exceeded_5_days = true
  #       end
  #     elsif appointment.last=='Catalyst Data'
  #       catalyst_datum = CatalystData.find(appointment.first)
  #       staff = Staff.find_by(catalyst_user_id: catalyst_datum.catalyst_user_id)
  #       client = Client.find_by(catalyst_patient_id: catalyst_datum.catalyst_patient_id)
  #       json.id catalyst_datum.id
  #       json.client_name "#{client&.first_name} #{client&.last_name}"
  #       json.client_id client&.id
  #       json.staff_name "#{staff&.first_name} #{staff&.last_name}"
  #       json.staff_id staff&.id
  #       json.date "#{catalyst_datum.date}"
  #       json.start_time "#{catalyst_datum.start_time}"
  #       json.end_time "#{catalyst_datum.end_time}"
  #       json.units "#{catalyst_datum.units}"
  #       json.minutes "#{catalyst_datum.minutes}"
  #       json.note catalyst_datum.note
  #       if catalyst_datum.is_appointment_found==false
  #         json.unrendered_reasons ["no_appointment_found"]
  #       else
  #         json.unrendered_reasons ["multiple_soap_notes_found"]
  #       end
  #     end
  #   end
  # end
  # json.exceeded_24_h exceeded_24_h
  # json.exceeded_3_days exceeded_3_days
  # json.exceeded_5_days exceeded_5_days

  json.todays_schedules do
    json.array! @todays_appointments do |schedule|
      client = schedule.client_enrollment_service&.client_enrollment&.client
      service = schedule.client_enrollment_service&.service
      json.id schedule.id
      json.client_enrollment_service_id schedule.client_enrollment_service_id
      json.cross_site_allowed schedule.cross_site_allowed
      json.client_id client&.id
      json.client_name "#{client.first_name} #{client.last_name}" if client.present?
      json.service_address_id schedule.service_address_id
      if schedule.service_address_id.present?
        service_address = Address.find_by(id: schedule.service_address_id)
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
      # json.is_rendered schedule.is_rendered
      if schedule.rendered_at.present?
        json.is_rendered true
      else
        json.is_rendered false
      end
      json.units schedule.units
      json.minutes schedule.minutes
      # if schedule.scheduling_change_requests.by_approval_status.any?
      #   json.request_raised 1
      # end
    end
  end
  if @past_schedules.exceeded_24_h_scheduling.any?
    json.exceeded_24_h true
  else
    json.exceeded_24_h false
  end
  if @past_schedules.exceeded_3_days_scheduling.any?
    json.exceeded_3_days true
  else
    json.exceeded_3_days false
  end
  if @past_schedules.exceeded_5_days_scheduling.any?
    json.exceeded_5_days true
  else
    json.exceeded_5_days false
  end
  # json.past_schedules do
  #   json.array! @past_schedules do |schedule|
  #     client = schedule.client_enrollment_service&.client_enrollment&.client
  #     service = schedule.client_enrollment_service&.service
  #     json.id schedule.id
  #     json.client_enrollment_service_id schedule.client_enrollment_service_id
  #     json.cross_site_allowed schedule.cross_site_allowed
  #     json.client_id client&.id
  #     json.client_name "#{client.first_name} #{client.last_name}" if client.present?
  #     json.service_address_id schedule.service_address_id
  #     if schedule.service_address_id.present?
  #       service_address = Address.find_by(id: schedule.service_address_id)
  #       if service_address.present?
  #         json.service_address do
  #           json.line1 service_address.line1
  #           json.line2 service_address.line2
  #           json.line3 service_address.line3
  #           json.zipcode service_address.zipcode
  #           json.city service_address.city
  #           json.state service_address.state
  #           json.country service_address.country
  #           json.is_default service_address.is_default
  #           json.address_name service_address.address_name
  #         end
  #       end
  #     end
  #     json.staff_id schedule.staff_id
  #     json.staff_name "#{schedule.staff.first_name} #{schedule.staff.last_name}" if schedule.staff.present?
  #     json.staff_role schedule.staff.role_name if schedule.staff.present?
  #     json.service_id service&.id
  #     json.service_name service&.name
  #     json.service_display_code service&.display_code 
  #     json.status schedule.status
  #     json.date schedule.date
  #     json.start_time schedule.start_time
  #     json.end_time schedule.end_time
  #     json.is_rendered schedule.is_rendered
  #     json.rendered_at schedule.rendered_at
  #     json.unrendered_reasons schedule.unrendered_reason
  #     json.units schedule.units
  #     json.minutes schedule.minutes
  #     if schedule.soap_notes.present? && schedule.soap_notes.last.catalyst_data_id.nil?
  #       json.soap_note do 
  #         soap_note = schedule.soap_notes.last
  #         json.id soap_note.id
  #         json.scheduling_id soap_note.scheduling_id
  #         json.note soap_note.note
  #         json.add_date soap_note.add_date
  #         json.rbt_sign soap_note.rbt_signature
  #         json.rbt_sign_name soap_note.rbt_signature_author_name
  #         json.rbt_sign_date soap_note.rbt_signature_date
  #         json.bcba_sign soap_note.bcba_signature
  #         json.bcba_sign_name soap_note.bcba_signature_author_name
  #         json.bcba_sign_date soap_note.bcba_signature_date&.strftime('%Y-%m-%d %H:%M')
  #         json.clinical_director_sign soap_note.clinical_director_signature
  #         json.clinical_director_sign_name soap_note.clinical_director_signature_author_name
  #         json.clinical_director_sign_date soap_note.clinical_director_signature_date
  #         json.caregiver_sign soap_note.signature_file&.blob&.service_url
  #         json.caregiver_sign_date soap_note.caregiver_signature_datetime
  #         json.synced_with_catalyst soap_note.synced_with_catalyst
  #       end
  #     elsif schedule.catalyst_data_ids.present?
  #       catalyst_datas = CatalystData.where(id: schedule.catalyst_data_ids).where(system_scheduling_id: schedule.id)
  #       if catalyst_datas.present?
  #         json.catalyst_data do
  #           json.array! catalyst_datas do |catalyst_data|
  #             staff = Staff.find_by(catalyst_user_id: catalyst_data.catalyst_user_id)
  #             client = Client.find_by(catalyst_patient_id: catalyst_data.catalyst_patient_id)
  #             json.id catalyst_data.id
  #             json.client_name "#{client&.first_name} #{client&.last_name}"
  #             json.staff_name "#{staff&.first_name} #{staff&.last_name}"
  #             json.date "#{catalyst_data.date}"
  #             json.start_time "#{catalyst_data.start_time}"
  #             json.end_time "#{catalyst_data.end_time}"
  #             json.units "#{catalyst_data.units}"
  #             json.minutes "#{catalyst_data.minutes}"
  #             json.note catalyst_data.note
  #             json.location catalyst_data.session_location
  #             json.cordinates catalyst_data.location
  #           end
  #         end
  #       end
  #     end
  #     if !(schedule.unrendered_reason.include?('units_does_not_match')) && !(schedule.unrendered_reason.include?('soap_note_absent'))
  #       json.soap_note_id schedule.soap_notes.last.id if schedule.soap_notes.present?
  #       json.synced_with_catalyst schedule.soap_notes.last.synced_with_catalyst if schedule.soap_notes.present?
  #     end
  #   end
  # end
  # json.catalyst_data do
  #   json.array! @catalyst_data do |catalyst_datum|
  #     staff = Staff.find_by(catalyst_user_id: catalyst_datum.catalyst_user_id)
  #     client = Client.find_by(catalyst_patient_id: catalyst_datum.catalyst_patient_id)
  #     json.id catalyst_datum.id
  #     json.client_name "#{client&.first_name} #{client&.last_name}"
  #     json.client_id client&.id
  #     json.staff_name "#{staff&.first_name} #{staff&.last_name}"
  #     json.staff_id staff&.id
  #     json.date "#{catalyst_datum.date}"
  #     json.start_time "#{catalyst_datum.start_time}"
  #     json.end_time "#{catalyst_datum.end_time}"
  #     json.units "#{catalyst_datum.units}"
  #     json.minutes "#{catalyst_datum.minutes}"
  #     json.note catalyst_datum.note
  #     json.location catalyst_datum.session_location
  #     json.cordinates catalyst_datum.location
  #     if catalyst_datum.is_appointment_found==false
  #       json.unrendered_reasons ["no_appointment_found"]
  #     else
  #       json.unrendered_reasons ["multiple_soap_notes_found"]
  #     end
  #   end
  # end
  json.action_items do
    json.array! @action_items_array do |action_item|
      if action_item.type=='Schedule'
        client = action_item.client_enrollment_service&.client_enrollment&.client
        service = action_item.client_enrollment_service&.service
        json.type 'schedule'
        json.id action_item.id
        json.client_enrollment_service_id action_item.client_enrollment_service_id
        json.cross_site_allowed action_item.cross_site_allowed
        json.client_id client&.id
        json.client_name "#{client.first_name} #{client.last_name}" if client.present?
        json.service_address_id action_item.service_address_id
        if action_item.service_address_id.present?
          service_address = Address.find_by(id: action_item.service_address_id)
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
        json.staff_id action_item.staff_id
        json.staff_name "#{action_item.staff.first_name} #{action_item.staff.last_name}" if action_item.staff.present?
        json.staff_role action_item.staff.role_name if action_item.staff.present?
        json.service_id service&.id
        json.service_name service&.name
        json.service_display_code service&.display_code 
        json.status action_item.status
        json.date action_item.date
        json.start_time action_item.start_time
        json.end_time action_item.end_time
        # json.is_rendered action_item.is_rendered
        if action_item.rendered_at.present?
          json.is_rendered true
        else
          json.is_rendered false
        end
        json.rendered_at action_item.rendered_at
        json.unrendered_reasons action_item.unrendered_reason
        json.units action_item.units
        json.minutes action_item.minutes
        if action_item.is_soap_notes_assigned==true
          if action_item.unrendered_reason.include?('units_does_not_match')
            catalyst_datas = CatalystData.where(id: action_item.catalyst_data_ids)
            json.catalyst_data do
              json.array! catalyst_datas do |catalyst_data|
                staff = Staff.where(catalyst_user_id: catalyst_data.catalyst_user_id)
                if staff.count==1
                  staff = staff.first
                elsif staff.count>1
                  staff = staff.find_by(status: 'active')
                else
                  staff = Staff.find_by(catalyst_user_id: catalyst_data.catalyst_user_id)
                end
                client = Client.where(catalyst_patient_id: catalyst_data.catalyst_patient_id)
                if client.count==1
                  client = client.first
                elsif client.count>1
                  client = client.find_by(status: 'active')
                else
                  client = Client.find_by(catalyst_patient_id: catalyst_data.catalyst_patient_id)
                end
                json.id catalyst_data.id
                json.client_name "#{client&.first_name} #{client&.last_name}"
                json.staff_name "#{staff&.first_name} #{staff&.last_name}"
                json.date "#{catalyst_data.date}"
                json.start_time "#{catalyst_data.start_time}"
                json.end_time "#{catalyst_data.end_time}"
                json.units "#{catalyst_data.units}"
                json.minutes "#{catalyst_data.minutes}"
                json.note catalyst_data.note
                json.location catalyst_data.session_location
                json.cordinates catalyst_data.location
              end
            end
          else
            soap_note = action_item.soap_notes.last
            if soap_note.present?
              json.soap_note do 
                json.id soap_note.id
                json.scheduling_id soap_note.scheduling_id
                json.note soap_note.note
                json.add_date soap_note.add_date
                json.rbt_sign soap_note.rbt_signature
                json.rbt_sign_name soap_note.rbt_signature_author_name
                json.rbt_sign_date soap_note.rbt_signature_date
                json.bcba_sign soap_note.bcba_signature
                json.bcba_sign_name soap_note.bcba_signature_author_name
                json.bcba_sign_date soap_note.bcba_signature_date&.strftime('%Y-%m-%d %H:%M')
                json.clinical_director_sign soap_note.clinical_director_signature
                json.clinical_director_sign_name soap_note.clinical_director_signature_author_name
                json.clinical_director_sign_date soap_note.clinical_director_signature_date
                json.caregiver_sign soap_note.signature_file&.blob&.service_url
                json.caregiver_sign_date soap_note.caregiver_signature_datetime
                json.synced_with_catalyst soap_note.synced_with_catalyst
              end
            end
          end
        else
          if action_item.soap_notes.where(synced_with_catalyst: false).present?
            json.soap_note do 
              soap_note = action_item.soap_notes.where(synced_with_catalyst: false).last
              json.id soap_note.id
              json.scheduling_id soap_note.scheduling_id
              json.note soap_note.note
              json.add_date soap_note.add_date
              json.rbt_sign soap_note.rbt_signature
              json.rbt_sign_name soap_note.rbt_signature_author_name
              json.rbt_sign_date soap_note.rbt_signature_date
              json.bcba_sign soap_note.bcba_signature
              json.bcba_sign_name soap_note.bcba_signature_author_name
              json.bcba_sign_date soap_note.bcba_signature_date&.strftime('%Y-%m-%d %H:%M')
              json.clinical_director_sign soap_note.clinical_director_signature
              json.clinical_director_sign_name soap_note.clinical_director_signature_author_name
              json.clinical_director_sign_date soap_note.clinical_director_signature_date
              json.caregiver_sign soap_note.signature_file&.blob&.service_url
              json.caregiver_sign_date soap_note.caregiver_signature_datetime
              json.synced_with_catalyst soap_note.synced_with_catalyst
            end
          end
          if action_item.catalyst_data_ids.present?
            catalyst_datas = CatalystData.where(id: action_item.catalyst_data_ids) #.where(system_scheduling_id: action_item.id)
            if catalyst_datas.present?
              json.catalyst_data do
                json.array! catalyst_datas do |catalyst_data|
                  staff = Staff.where(catalyst_user_id: catalyst_data.catalyst_user_id)
                  if staff.count==1
                    staff = staff.first
                  elsif staff.count>1
                    staff = staff.find_by(status: 'active')
                  else
                    staff = Staff.find_by(catalyst_user_id: catalyst_data.catalyst_user_id)
                  end
                  client = Client.where(catalyst_patient_id: catalyst_data.catalyst_patient_id)
                  if client.count==1
                    client = client.first
                  elsif client.count>1
                    client = client.find_by(status: 'active')
                  else
                    client = Client.find_by(catalyst_patient_id: catalyst_data.catalyst_patient_id)
                  end
                  json.id catalyst_data.id
                  json.client_name "#{client&.first_name} #{client&.last_name}"
                  json.staff_name "#{staff&.first_name} #{staff&.last_name}"
                  json.date "#{catalyst_data.date}"
                  json.start_time "#{catalyst_data.start_time}"
                  json.end_time "#{catalyst_data.end_time}"
                  json.units "#{catalyst_data.units}"
                  json.minutes "#{catalyst_data.minutes}"
                  json.note catalyst_data.note
                  json.location catalyst_data.session_location
                  json.cordinates catalyst_data.location
                end
              end
            end
          end
        end
        if !(action_item.unrendered_reason.include?('units_does_not_match')) && !(action_item.unrendered_reason.include?('soap_note_absent'))
          json.soap_note_id action_item.soap_notes.last.id if action_item.soap_notes.present?
          json.synced_with_catalyst action_item.soap_notes.last.synced_with_catalyst if action_item.soap_notes.present?
        end
      else
        staff = Staff.where(catalyst_user_id: action_item.catalyst_user_id)
        if staff.count==1
          staff = staff.first
        elsif staff.count>1
          staff = staff.find_by(status: 'active')
        else
          staff = Staff.find_by(catalyst_user_id: action_item.catalyst_user_id)
        end
        client = Client.where(catalyst_patient_id: action_item.catalyst_patient_id)
        if client.count==1
          client = client.first
        elsif client.count>1
          client = client.find_by(status: 'active')
        else
          client = Client.find_by(catalyst_patient_id: action_item.catalyst_patient_id)
        end
        json.id action_item.id
        json.type 'catalyst_data'
        json.client_name "#{client&.first_name} #{client&.last_name}"
        json.client_id client&.id
        json.staff_name "#{staff&.first_name} #{staff&.last_name}"
        json.staff_id staff&.id
        json.date "#{action_item.date}"
        json.start_time "#{action_item.start_time}"
        json.end_time "#{action_item.end_time}"
        json.units "#{action_item.units}"
        json.minutes "#{action_item.minutes}"
        json.note action_item.note
        json.location action_item.session_location
        json.cordinates action_item.location
        json.unrendered_reasons ["no_appointment_found"] if action_item.system_scheduling_id.blank?
        # if action_item.is_appointment_found==false
        #   json.unrendered_reasons ["no_appointment_found"]
        # else
        #   json.unrendered_reasons ["multiple_appointments_found"]
        # end
      end
    end
  end
end
