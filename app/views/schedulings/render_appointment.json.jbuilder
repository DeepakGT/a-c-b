json.status 'success'
json.data do
  json.partial! 'scheduling_detail', schedule: @schedule
  if @schedule.client_enrollment_service.present? && @schedule.client_enrollment_service.staff.present?
    json.partial! 'client_enrollment_services/service_provider_detail', enrollment_service: @schedule.client_enrollment_service, object_type: nil
  end
end
