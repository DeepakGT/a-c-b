json.status 'success' 
json.data do
  primary_client_enrollment = @client.client_enrollments.active.order(is_primary: :desc).first
  json.id @client.id
  json.first_name @client.first_name
  json.last_name @client.last_name
  json.email @client.email
  json.clinic_id @client.clinic_id
  json.clinic_name @client.clinic.name
  json.email @client.email
  json.dob @client.dob
  json.gender @client.gender
  json.status @client.status
  json.preferred_language @client.preferred_language
  json.disqualified @client.disqualified
  json.disqualified_reason @client.dq_reason if @client.disqualified?
  json.payor_status @client.payor_status
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
        json.units schedule.units
        json.minutes schedule.minutes
      end
    end
  end
  if @soap_notes.present?
    json.soap_notes do
      json.array! @soap_notes do |soap_note|
        user = User.find(soap_note.creator_id)
        json.id soap_note.id
        json.scheduling_id soap_note.scheduling_id
        json.note soap_note.note
        json.add_date soap_note.add_date
        json.creator_id user&.id
        json.creator "#{user&.first_name} #{user&.last_name}"
      end
    end
  end
  if @notes.present?
    json.notes do
      json.array! @notes do |note|
        user = User.find(note.creator_id)
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
