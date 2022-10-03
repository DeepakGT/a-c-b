json.status 'success' 
json.data do
  primary_client_enrollment = @client.client_enrollments.active&.order(is_primary: :desc)&.first
  json.partial! 'clients/client_detail', client: @client
  json.created_date @client.created_at&.strftime('%Y-%m-%d')
  json.days_since_creation @client.days_since_creation
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
        json.partial! 'schedulings/scheduling_detail', schedule: schedule
      end
    end
  end
  if @client_enrollment_services.present?
    json.client_enrollment_services do
      json.array! @client_enrollment_services do |client_enrollment_service|
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
        next unless attachment.can_be_displayed?(current_user.role_name)

        json.partial! 'client_attachments/attachment_detail', attachment: attachment
      end
    end
  end
end
