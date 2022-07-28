json.status 'success' 
json.data do
  primary_client_enrollment = @client.client_enrollments.active&.order(is_primary: :desc)&.first
  json.partial! 'clients/client_detail', client: @client
  json.created_date @client.created_at&.strftime('%Y-%m-%d')
  if primary_client_enrollment.present?
    if primary_client_enrollment.source_of_payment=='self_pay' || primary_client_enrollment.funding_source.blank?
      json.payor nil
    else
      json.payor primary_client_enrollment.funding_source.name
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
        if (client_enrollment_service.used_units + client_enrollment_service.scheduled_units)>=(0.9 * client_enrollment_service.units)
          json.is_exhausted true
        else
          json.is_exhausted false
        end
        if client_enrollment_service.end_date > (Time.current.to_date + 9)
          json.about_to_expire false
        else
          json.about_to_expire true
        end
        json.partial! 'client_enrollment_services/client_enrollment_service_detail', enrollment_service: client_enrollment_service
      end
    end
  end
  if @soap_notes.present?
    json.soap_notes do
      json.array! @soap_notes do |soap_note|
        json.partial! 'soap_notes/soap_note_detail', soap_note: soap_note
      end
    end
  end
  if @notes.present?
    json.notes do
      json.array! @notes do |note|
        json.partial! 'client_notes/client_note_detail', client_note: note
      end
    end
  end
  if @attachments.present?
    json.attachments do
      json.array! @attachments do |attachment|
        json.partial! 'client_attachments/attachment_detail', attachment: attachment
      end
    end
  end
end
