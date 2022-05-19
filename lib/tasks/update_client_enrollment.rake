namespace :update_client_enrollment do
  desc "Update primary client enrollment"
  task update_primary_client_enrollment: :environment do
    Client.all.each do |client|
      if client.client_enrollments.where(is_primary: true).blank?
        client_enrollments = client.client_enrollments.active
        if client_enrollments.present?
          client_enrollment = client_enrollments.order(:id).first
          client_enrollment.is_primary = true
          client_enrollment.save(validate: false)
        end
      end
    end 
  end
end
