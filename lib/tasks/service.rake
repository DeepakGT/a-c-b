namespace :service do
  desc 'Update early code flag'
  task update_is_early_code: :environment do
    # Updating ABA Centers of America as non billable payor
    funding_source = FundingSource.find_by(name: 'ABA Centers of America')
    funding_source.network_status = 'non_billable'
    funding_source.save(validate: false) # since there might be some non early services provided by ABA centers updating without validating
    services = Service.where(display_code: ['99997', '99998', '99999', '98888'])
    funding_source_id = FundingSource.find_by_name('ABA Centers of America')&.id
    services.each do |service|
      case service.display_code
      when '98888'
        service_id_to_replace = Service.find_by(name: 'Assessment Support by Technician')&.id
      when '99997'
        service_id_to_replace = Service.find_by(name: 'Protocol Modification/Supervision')&.id
      when '99998'
        service_id_to_replace = Service.find_by(name: 'Caregiver Training')&.id
      when '99999'
        service_id_to_replace = Service.find_by(name: 'Direct Service')&.id
      end
      enrollment_services = service.client_enrollment_services
      enrollment_services.each do |enrollment_service|
        client_enrollment = enrollment_service.client_enrollment
        client = client_enrollment.client
        if client_enrollment&.funding_source&.name != 'ABA Centers of America'
          if client.client_enrollments.where(funding_source_id: funding_source_id).present?
            client_enrollment = client.client_enrollments.where(funding_source_id: funding_source_id)&.order(:created_at)&.last
            client_enrollment.update(terminated_on: enrollment_service.end_date) if client_enrollment.terminated_on < enrollment_service.end_date
          else
            client_enrollment = ClientEnrollment.find_or_create_by(client_id: client_enrollment.client_id, funding_source_id: funding_source_id, source_of_payment: 'insurance', terminated_on: client_enrollment.terminated_on)
          end
        end
          enrollment_service.client_enrollment_id = client_enrollment.id
          enrollment_service.save(validate: false)
        # else
          # puts "#{client_enrollment&.funding_source&.name} present client #{client_enrollment&.client&.id}"
          # enrollment_service.update(client_enrollment_id: client_enrollment.id)
        # end
      end
      service.update(is_early_code: true, selected_payors: [{payor_id: funding_source_id, is_legacy_required:false}]&.to_json, max_units: 100, selected_non_early_service_id: service_id_to_replace)
    end
  end
end
