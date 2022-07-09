namespace :update_client_enrollment do
  desc "Update primary client enrollment"
  task update_primary_client_enrollment: :environment do
    Client.all.each do |client|
      if client.client_enrollments.where(is_primary: true).blank?
        client_enrollments = client.client_enrollments.active
        if client_enrollments.present?
          if client_enrollments.count > 1
            ordered_client_enrollments = client_enrollments.joins(client_enrollment_services: :schedulings).select('COUNT(schedulings.*) as scheduling_count, client_enrollments.*').group('id').having('count(client_enrollment_services.*) > ?', 0).order('scheduling_count DESC')
            if ordered_client_enrollments.present?
              client_enrollment = ordered_client_enrollments.first
              client_enrollment.is_primary = true
              client_enrollment.save(validate: false)
            else
              client_enrollment = client_enrollments.first
              client_enrollment.is_primary = true
              client_enrollment.save(validate: false)
            end
          else
            client_enrollment = client_enrollments.first
            client_enrollment.is_primary = true
            client_enrollment.save(validate: false)
          end
        end
      end
    end 
  end
end
