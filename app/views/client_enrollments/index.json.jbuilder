json.status 'success'
json.data do
  json.array! @client_enrollments do |client_enrollment|
    json.id client_enrollment.id
    json.client_id client_enrollment.client_id
    json.source_of_payment client_enrollment.source_of_payment
    json.funding_source_id client_enrollment.funding_source_id
    json.funding_source client_enrollment.funding_source&.name
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
        # schedules = Scheduling.by_client_and_service(enrollment_service.client_enrollment.client_id, enrollment_service.service_id)
        # schedules = schedules.with_rendered_or_scheduled_as_status
        # completed_schedules = schedules.completed_scheduling
        # scheduled_schedules = schedules.scheduled_scheduling
        # used_units = completed_schedules.with_units.pluck(:units).sum
        # scheduled_units = scheduled_schedules.with_units.pluck(:units).sum
        # used_minutes = completed_schedules.with_minutes.pluck(:minutes).sum
        # scheduled_minutes = scheduled_schedules.with_minutes.pluck(:minutes).sum
        json.id enrollment_service.id
        json.service_id enrollment_service.service_id
        json.service_name enrollment_service.service&.name
        json.service_display_code enrollment_service.service&.display_code
        json.is_service_provider_required enrollment_service.service&.is_service_provider_required
        json.start_date enrollment_service.start_date
        json.end_date enrollment_service.end_date
        if enrollment_service.end_date.present? && enrollment_service.end_date > (Time.current.to_date + 9)
          json.about_to_expire false
        else
          json.about_to_expire true
        end
        json.units enrollment_service.units
        json.used_units enrollment_service.used_units
        json.scheduled_units enrollment_service.scheduled_units
        json.left_units enrollment_service.left_units
        if (enrollment_service.used_units + enrollment_service.scheduled_units)>=(0.9 * enrollment_service.units)
          json.is_exhausted true
        else
          json.is_exhausted false
        end
        # if enrollment_service.units.present?
        #   json.left_units enrollment_service.units - (used_units + scheduled_units) 
        #   if (used_units + scheduled_units)>=(0.9 * enrollment_service.units)
        #     json.is_exhausted true
        #   else
        #     json.is_exhausted false
        #   end
        # else
        #   json.left_units 0
        # end
        json.minutes enrollment_service.minutes
        json.used_minutes enrollment_service.used_minutes
        json.scheduled_minutes enrollment_service.scheduled_minutes
        json.left_minutes enrollment_service.left_minutes
        if (enrollment_service.used_minutes + enrollment_service.scheduled_minutes)>=(0.9 * enrollment_service.minutes)
          json.is_exhausted true
        else
          json.is_exhausted false
        end
        # if enrollment_service.minutes.present?
        #   json.left_minutes enrollment_service.minutes - (used_minutes + scheduled_minutes)
        #   if (used_minutes + scheduled_minutes)>=(0.9 * enrollment_service.minutes)
        #     json.is_exhausted true
        #   else
        #     json.is_exhausted false
        #   end
        # else
        #   json.left_minutes 0
        # end
        json.service_number enrollment_service.service_number
        json.service_providers do
          json.ids enrollment_service.service_providers.pluck(:staff_id)
          json.names enrollment_service.staff&.map{|staff| "#{staff.first_name} #{staff.last_name}"}
        end
      end
    end
  end
end
if params[:page].present?
  json.total_records @client_enrollments.total_entries
  json.limit @client_enrollments.per_page
  json.page params[:page]
end
