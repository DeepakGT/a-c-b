json.status 'success' 
json.data do
  primary_client_enrollment = @client.client_enrollments.active&.order(is_primary: :desc)&.first
  json.id @client.id
  json.first_name @client.first_name
  json.last_name @client.last_name
  json.email @client.email
  json.clinic_id @client.clinic_id
  json.clinic_name @client.clinic.name
  json.bcba_id @client.bcba_id
  json.bcba_name "#{@client.bcba&.first_name} #{@client.bcba&.last_name}"
  json.email @client.email
  json.dob @client.dob
  json.gender @client.gender
  json.status @client.status
  json.tracking_id @client.tracking_id
  json.preferred_language @client.preferred_language
  json.disqualified @client.disqualified
  json.disqualified_reason @client.dq_reason if @client.disqualified?
  json.payor_status @client.payor_status
  json.created_date @client.created_at&.strftime('%Y-%m-%d')
  if primary_client_enrollment.present?
    if primary_client_enrollment.source_of_payment=='self_pay' || primary_client_enrollment.funding_source.blank?
      json.payor nil
    else
      json.payor primary_client_enrollment.funding_source.name
    end
  end
  if @client.addresses.present?
    json.addresses do
      json.array! @client.addresses do |address|
        json.id address.id
        json.type address.address_type
        json.line1 address.line1
        json.line2 address.line2
        json.line3 address.line3
        json.zipcode address.zipcode
        json.city address.city
        json.state address.state
        json.country address.country
        json.is_default address.is_default if address.address_type=='service_address'
      end
    end
  end
  if @client.phone_number.present?
    json.phone_number do
      json.id @client.phone_number.id
      json.phone_type @client.phone_number.phone_type
      json.number @client.phone_number.number
    end
  end
  if @schedules.present?
    json.schedules do
      json.array! @schedules do |schedule|
        service = schedule.client_enrollment_service&.service
        json.id schedule.id
        json.client_enrollment_service_id schedule.client_enrollment_service_id
        json.staff_id schedule.staff_id
        json.staff_name "#{schedule.staff.first_name} #{schedule.staff.last_name}" if schedule.staff.present?
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
  end
  if @client_enrollment_services.present?
    json.client_enrollment_services do
      json.array! @client_enrollment_services do |client_enrollment_service|
        # schedules = Scheduling.by_client_and_service(@client_id, client_enrollment_service.service_id)
        # schedules = schedules.with_rendered_or_scheduled_as_status
        # completed_schedules = schedules.completed_scheduling
        # scheduled_schedules = schedules.scheduled_scheduling
        # used_units = completed_schedules.with_units.pluck(:units).sum
        # scheduled_units = scheduled_schedules.with_units.pluck(:units).sum
        # used_minutes = completed_schedules.with_minutes.pluck(:minutes).sum
        # scheduled_minutes = scheduled_schedules.with_minutes.pluck(:minutes).sum
        json.id client_enrollment_service.id
        json.service_id client_enrollment_service.service_id
        json.service_name client_enrollment_service.service&.name
        json.service_display_code client_enrollment_service.service&.display_code
        json.is_service_provider_required client_enrollment_service.service&.is_service_provider_required
        json.start_date client_enrollment_service.start_date
        json.end_date client_enrollment_service.end_date
        if client_enrollment_service.end_date > (Time.current.to_date + 9)
          json.about_to_expire false
        else
          json.about_to_expire true
        end
        json.units client_enrollment_service.units
        json.used_units client_enrollment_service.used_units
        json.scheduled_units client_enrollment_service.scheduled_units
        json.left_units client_enrollment_service.left_units
        if (client_enrollment_service.used_units + client_enrollment_service.scheduled_units)>=(0.9 * client_enrollment_service.units)
          json.is_exhausted true
        else
          json.is_exhausted false
        end
        # if client_enrollment_service.units.present?
        #   json.left_units client_enrollment_service.units - (used_units + scheduled_units) 
        #   if (used_units + scheduled_units)>=(0.9 * client_enrollment_service.units)
        #     json.is_exhausted true
        #   else
        #     json.is_exhausted false
        #   end
        # else
        #   json.left_units 0
        # end
        json.minutes client_enrollment_service.minutes
        json.used_minutes client_enrollment_service.used_minutes
        json.scheduled_minutes client_enrollment_service.scheduled_minutes
        json.left_minutes client_enrollment_service.left_minutes
        if (client_enrollment_service.used_minutes + client_enrollment_service.scheduled_minutes)>=(0.9 * client_enrollment_service.minutes)
          json.is_exhausted true
        else
          json.is_exhausted false
        end
        # if client_enrollment_service.minutes.present?
        #   json.left_minutes client_enrollment_service.minutes - (used_minutes + scheduled_minutes)
        #   if (used_minutes + scheduled_minutes)>=(0.9 * client_enrollment_service.minutes)
        #     json.is_exhausted true
        #   else
        #     json.is_exhausted false
        #   end
        # else
        #   json.left_minutes 0
        # end
        json.service_number client_enrollment_service.service_number
        json.service_providers do
          json.ids client_enrollment_service.service_providers.pluck(:staff_id)
          json.names client_enrollment_service.staff&.map{|staff| "#{staff.first_name} #{staff.last_name}"}
        end
      end
    end
  end
  if @soap_notes.present?
    json.soap_notes do
      json.array! @soap_notes do |soap_note|
        user = User.find_by(id: soap_note.creator_id)
        json.id soap_note.id
        json.scheduling_id soap_note.scheduling_id
        json.note soap_note.note
        json.add_date soap_note.add_date
        json.add_time soap_note.add_time&.strftime('%H:%M')
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
        if soap_note.synced_with_catalyst.to_bool.true?
          json.caregiver_sign_present soap_note.caregiver_signature
          catalyst_data = CatalystData.find_by(id: soap_note.catalyst_data_id)
          json.location catalyst_data.session_location
          json.cordinates catalyst_data.location
        else
          json.location nil
          json.cordinates nil
        end
        json.creator_id user&.id
        json.creator "#{user&.first_name} #{user&.last_name}"
        if soap_note.synced_with_catalyst.to_bool.true?
          json.caregiver_sign_present soap_note.caregiver_signature
        end
      end
    end
  end
  if @notes.present?
    json.notes do
      json.array! @notes do |note|
        user = User.where(id: note.creator_id)&.first
        json.id note.id
        json.note note.note
        json.add_date note.add_date
        json.creator_id user&.id
        json.creator "#{user&.first_name} #{user&.last_name}"
      end
    end
  end
  if @attachments.present?
    json.attachments do
      json.array! @attachments do |attachment|
        json.id attachment.id
        json.category attachment.category
        json.file_name attachment.file_name
        json.url attachment.file.blob&.service_url
        json.add_date attachment.created_at.to_date
      end
    end
  end
end
