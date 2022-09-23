namespace :update_partial_scheduling do
    desc "Update client_id in soap_notes"
    task update_status_to_auth_pending: :environment do
        schedules = Scheduling.where(status: "Scheduled").where.not(rendered_at: nil)
        early_codes = ['99997', '99998', '99999']
        schedules.each do |schedule|
            service_code = schedule.client_enrollment_service.service.display_code
            puts "schedule ID - #{schedule.id}, Service Code - #{service_code}"
            schedule.update(status: 'auth_pending', rendered_at: nil) if early_codes.include? service_code
        end
    end
  end
  