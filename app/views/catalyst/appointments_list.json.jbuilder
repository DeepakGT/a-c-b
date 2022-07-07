json.status 'success'
json.data do
  staff = Staff.where(catalyst_user_id: @catalyst_data.catalyst_user_id)
  if staff.count==1
    staff = staff.first
  elsif staff.count>1
    staff = staff.find_by(status: 'active')
  else
    staff = Staff.find_by(catalyst_user_id: @catalyst_data.catalyst_user_id)
  end
  client = Client.where(catalyst_patient_id: @catalyst_data.catalyst_patient_id)
  if client.count==1
    client = client.first
  elsif client.count>1
    client = client.find_by(status: 'active')
  else
    client = Client.find_by(catalyst_patient_id: @catalyst_data.catalyst_patient_id)
  end
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
      json.unrendered_reasons schedule.unrendered_reason
      json.units schedule.units
      json.minutes schedule.minutes
      soap_note = schedule.soap_notes&.order(add_date: :desc, add_time: :desc).first
      if soap_note.present?
        json.soap_note do
          json.id soap_note.id
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
          json.synced_with_catalyst soap_note.synced_with_catalyst
          if soap_note.synced_with_catalyst.to_bool.true?
            json.caregiver_sign_present soap_note.caregiver_signature
            catalyst_data = CatalystData.find_by(id: soap_note.catalyst_data_id)
            json.location catalyst_data&.session_location
            json.cordinates catalyst_data&.location
          else
            json.location nil
            json.cordinates nil
          end
        end
      end
    end
  end
end
