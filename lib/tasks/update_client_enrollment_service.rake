namespace :update_client_enrollment_service do
  desc "remove service_providers for those services that have rendering_service false"
  task remove_service_providers: :environment do
    client_enrollment_services = ClientEnrollmentService.joins(:service).where('service.is_service_provider_required': false)
    client_enrollment_services.map{|service| service.service_providers&.destroy_all }
  end
end
