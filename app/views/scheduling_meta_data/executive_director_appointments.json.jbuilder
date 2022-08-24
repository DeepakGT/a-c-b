json.status 'success'
json.data do
  if Setting.first&.roles_ids.include?(current_user&.role&.id)
    json.setting_data Setting.first&.welcome_note
  else
    json.setting_data nil
  end

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
      if schedule.rendered_at.present? && schedule.status == 'Rendered'
        json.is_rendered true
      else
        json.is_rendered false
      end
      json.units schedule.units
      json.minutes schedule.minutes
    end
  end
  if @past_schedules.any?
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
  json.client_enrollment_services do
    json.array! @client_enrollment_services do |client_enrollment_service|
      # schedules = Scheduling.by_client_and_service(client_enrollment_service.client_enrollment.client_id, client_enrollment_service.service_id)
      # schedules = schedules.with_rendered_or_scheduled_as_status
      # completed_schedules = schedules.completed_scheduling
      # scheduled_schedules = schedules.scheduled_scheduling
      # used_units = completed_schedules.with_units.pluck(:units).sum
      # scheduled_units = scheduled_schedules.with_units.pluck(:units).sum
      # used_minutes = completed_schedules.with_minutes.pluck(:minutes).sum
      # scheduled_minutes = scheduled_schedules.with_minutes.pluck(:minutes).sum
      json.id client_enrollment_service.id
      json.client_id client_enrollment_service.client_enrollment&.client_id
      json.client_name "#{client_enrollment_service.client_enrollment&.client&.first_name} #{client_enrollment_service.client_enrollment&.client&.last_name}"
      json.client_enrollment_id client_enrollment_service.client_enrollment_id
      json.funding_source_id client_enrollment_service.client_enrollment.funding_source_id
      json.funding_source client_enrollment_service.client_enrollment.funding_source&.name
      json.service_id client_enrollment_service.service_id
      json.service client_enrollment_service.service&.name
      json.service_display_code client_enrollment_service.service&.display_code
      json.is_service_provider_required client_enrollment_service.service&.is_service_provider_required
      json.start_date client_enrollment_service.start_date
      json.end_date client_enrollment_service.end_date
      json.units client_enrollment_service.units
      json.used_units client_enrollment_service.used_units
      json.scheduled_units client_enrollment_service.scheduled_units
      json.left_units client_enrollment_service.left_units
      # if client_enrollment_service.units.present?
      #   json.left_units client_enrollment_service.units - (used_units + scheduled_units) 
      # else
      #   json.left_units 0
      # end
      json.minutes client_enrollment_service.minutes
      json.used_minutes client_enrollment_service.used_minutes
      json.scheduled_minutes client_enrollment_service.scheduled_minutes
      json.left_minutes client_enrollment_service.left_minutes
      # if client_enrollment_service.minutes.present?
      #   json.left_minutes client_enrollment_service.minutes - (used_minutes + scheduled_minutes)
      # else
      #   json.left_minutes 0
      # end
      json.service_number client_enrollment_service.service_number
      json.service_providers do
        json.ids client_enrollment_service.service_providers.pluck(:id)
        json.staff_ids client_enrollment_service.service_providers.pluck(:staff_id)
        json.names client_enrollment_service.staff&.map{|staff| ("#{staff.first_name} #{staff.last_name}")}
      end
    end
  end
  json.change_requests do
    json.array! @change_requests do |change_request|
      service = change_request.scheduling&.client_enrollment_service&.service
      client = change_request.scheduling&.client_enrollment_service&.client_enrollment&.client
      json.id change_request.id
      json.date change_request.date
      json.start_time change_request.start_time
      json.end_time change_request.end_time
      json.status change_request.status
      json.approval_status change_request.approval_status
      json.scheduling_id change_request.scheduling_id
      json.scheduling_date change_request.scheduling.date
      json.scheduling_start_time change_request.scheduling.start_time
      json.scheduling_end_time change_request.scheduling.end_time
      json.scheduling_status change_request.scheduling.status
      json.staff_id change_request.scheduling.staff_id
      json.staff_name "#{change_request.scheduling.staff.first_name} #{change_request.scheduling.staff.last_name}" if change_request.scheduling.staff.present?
      json.staff_role change_request.scheduling.staff.role_name if change_request.scheduling.staff.present?
      json.client_id client&.id
      json.client_name "#{client.first_name} #{client.last_name}" if client.present?
      json.service_id service&.id
      json.service_name service&.name
      json.service_display_code service&.display_code
    end
  end
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
  json.unassigned_appointments do
    json.array! @unassigned_appointments do |schedule|
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
      json.staff_role schedule.staff.role_name if schedule.staff.present?
      json.service_id service&.id
      json.service_name service&.name
      json.service_display_code service&.display_code 
      json.status schedule.status
      json.date schedule.date
      json.start_time schedule.start_time
      json.end_time schedule.end_time
      # json.is_rendered schedule.is_rendered
      if schedule.rendered_at.present? && schedule.status == 'Rendered'
        json.is_rendered true
      else
        json.is_rendered false
      end
      json.units schedule.units
      json.minutes schedule.minutes
    end
  end
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
        if action_item.rendered_at.present? && action_item.status == 'Rendered'
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
                json.is_deleted_from_connect catalyst_data.is_deleted_from_connect
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
                  json.is_deleted_from_connect catalyst_data.is_deleted_from_connect
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
        json.is_deleted_from_connect action_item.is_deleted_from_connect
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
  json.action_items_count @total_count
end
if params[:page].present?
  json.total_records @action_items_array&.total_entries
  json.limit @action_items_array&.per_page
  json.page params[:page]
end
