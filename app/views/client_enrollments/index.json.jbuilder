json.status 'success'
json.data do
  json.array! @client_enrollments do |client_enrollment|
    json.id client_enrollment.id
    json.client_id client_enrollment.client_id
    json.source_of_payment client_enrollment.source_of_payment
    json.funding_source_id client_enrollment.funding_source_id
    if client_enrollment.funding_source.present?
      json.funding_source client_enrollment.funding_source.name 
    end
    json.terminated_on client_enrollment.terminated_on
    json.primary client_enrollment.is_primary
    json.insurance_id client_enrollment.insurance_id
    json.group client_enrollment.group
    json.group_employer client_enrollment.group_employer
    json.provider_phone client_enrollment.provider_phone
    json.relationship client_enrollment.relationship
    json.subscriber_name client_enrollment.subscriber_name
    json.subscriber_phone client_enrollment.subscriber_phone
    json.subscriber_dob client_enrollment.subscriber_dob
    json.services do
      json.array! client_enrollment.client_enrollment_services do |enrollment_service|
        json.id enrollment_service.id
        json.service_id enrollment_service.service_id
        json.service_name enrollment_service.service.name
        json.start_date enrollment_service.start_date
        json.end_date enrollment_service.end_date
        json.units enrollment_service.units
        json.minutes enrollment_service.minutes
        json.service_number enrollment_service.service_number
        json.service_providers do
          json.ids enrollment_service.service_providers.pluck(:staff_id)
          json.names enrollment_service.staff.map{|staff| "#{staff.first_name} #{staff.last_name}"}
        end
      end
    end
  end
end
json.total_records @client_enrollments.total_entries
json.limit @client_enrollments.per_page
json.page params[:page] || 1
