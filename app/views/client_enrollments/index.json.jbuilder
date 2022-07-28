json.status 'success'
json.data do
  json.array! @client_enrollments do |client_enrollment|
    json.partial! 'client_enrollment_detail', client_enrollment: client_enrollment
    json.services do
      if params[:show_expired_before_30_days].to_bool.true?
        client_enrollment_services = client_enrollment.client_enrollment_services
      else
        client_enrollment_services = client_enrollment.client_enrollment_services.not_expired_before_30_days
      end
      json.array! client_enrollment_services do |enrollment_service|
        if enrollment_service.end_date.present? && enrollment_service.end_date > (Time.current.to_date + 9)
          json.about_to_expire false
        else
          json.about_to_expire true
        end
        if (enrollment_service.used_units + enrollment_service.scheduled_units)>=(0.9 * enrollment_service.units)
          json.is_exhausted true
        else
          json.is_exhausted false
        end
        json.partial! '/client_enrollment_services/client_enrollment_service_detail', enrollment_service: enrollment_service
      end
    end
  end
end
if params[:page].present?
  json.total_records @client_enrollments.total_entries
  json.limit @client_enrollments.per_page
  json.page params[:page]
end
