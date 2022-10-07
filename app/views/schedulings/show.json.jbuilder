json.status 'success'
json.data do
  json.partial! 'scheduling_detail', schedule: @schedule
  if @schedule.client_enrollment_service.present? && @schedule.client_enrollment_service.staff.present?
    json.partial! 'client_enrollment_services/service_provider_detail', enrollment_service: @schedule.client_enrollment_service, object_type: nil
  end
  if @schedule.soap_notes.present?
    json.soap_notes do
      json.array! @schedule.soap_notes do |soap_note|
        json.partial! 'soap_notes/soap_note_detail', soap_note: soap_note
      end
    end
  end
  json.audits do
    json.array! @schedule.audits.sort_by(&:created_at).reverse do |audit|
      if audit.user_type.present? && audit.user_type == 'User'
        auditor = User.find_by(id: audit.user_id) 
        json.auditor_name "#{auditor&.first_name} #{auditor&.last_name}"
      else
        json.auditor_name "#{audit.user_type || 'System'}"
      end
      json.audited_changes audit.audited_changes
      json.audited_at audit.created_at
      json.action audit.action
    end
  end
end
