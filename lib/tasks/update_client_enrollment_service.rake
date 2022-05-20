namespace :update_client_enrollment_service do
  desc "remove service_providers for those services that have rendering_service false"
  task remove_service_providers: :environment do
    client_enrollment_services = ClientEnrollmentService.joins(:service).where('service.is_service_provider_required': false)
    client_enrollment_services.map{|service| service.service_providers&.destroy_all }
  end

  desc "update all units and minutes columns"
  task update_units_and_minutes_columns: :environment do
    ClientEnrollmentService.all.each do |client_enrollment_service|
      schedules = client_enrollment_service.schedulings
      schedules = schedules.with_rendered_or_scheduled_as_status
      completed_schedules = schedules.completed_scheduling
      scheduled_schedules = schedules.scheduled_scheduling
      used_units = completed_schedules.with_units.pluck(:units).sum
      used_units = 0 if used_units.blank?
      scheduled_units = scheduled_schedules.with_units.pluck(:units).sum
      scheduled_units = 0 if scheduled_units.blank?
      left_units = if client_enrollment_service.units.present?
        client_enrollment_service.units - (used_units + scheduled_units) 
      else
        0
      end

      used_minutes = completed_schedules.with_minutes.pluck(:minutes).sum
      used_minutes = 0 if used_minutes.blank?
      scheduled_minutes = scheduled_schedules.with_minutes.pluck(:minutes).sum
      scheduled_minutes = 0 if scheduled_minutes.blank?
      left_minutes = if client_enrollment_service.minutes.present?
        client_enrollment_service.minutes - (used_minutes + scheduled_minutes)
      else
        0
      end

      client_enrollment_service.left_units = left_units
      client_enrollment_service.used_units = used_units
      client_enrollment_service.scheduled_units = scheduled_units

      client_enrollment_service.left_minutes = left_minutes
      client_enrollment_service.used_minutes = used_minutes
      client_enrollment_service.scheduled_minutes = scheduled_minutes

      client_enrollment_service.save(validate: false)
    end
  end
end
