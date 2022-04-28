module Snowflake
  module SeedSchedulingDataOperation
    class << self
      def call(username, password)
        seed_scheduling_data(username, password)
      end

      private

      def seed_scheduling_data(username, password)
        db = Snowflake::SetDatabaseAndWarehouseService.call(username, password)
        appointments = Snowflake::GetAppointmentAdminDataService.call(db)
        
        appointments.each do |appointment|
          appointment = appointment.with_indifferent_access
          client_name = appointment['clientname']&.split(',')&.each(&:strip!)
          client = Client.find_by(dob: appointment['clientdob']&.to_time&.strftime('%Y-%m-%d'), first_name: client_name&.last, last_name: client_name&.first)
          if client.present?
            funding_source_id = get_funding_source(appointment['fundingsource'])
            if funding_source_id.present?
              client_enrollment = client&.client_enrollments&.find_by(source_of_payment: 'insurance', funding_source_id: funding_source_id, enrollment_date: appointment['servicefundingbegin']&.to_time&.strftime('%Y-%m-%d'), terminated_on: appointment['servicefundingend']&.to_time&.strftime('%Y-%m-%d'))
            elsif appointment['fundingsource']==nil
              client_enrollment = client&.client_enrollments&.find_by(source_of_payment: 'self_pay', enrollment_date: appointment['servicefundingbegin']&.to_time&.strftime('%Y-%m-%d'), terminated_on: appointment['servicefundingend']&.to_time&.strftime('%Y-%m-%d'))
            end
            if client_enrollment.present?
              service = Service.where('lower(name) = ?',appointment['servicename'].downcase).first
              if service.present?
                client_enrollment_service = client_enrollment.client_enrollment_services.find_by(service_id: service.id, start_date: appointment['servicestart']&.to_time&.strftime('%Y-%m-%d'), end_date: appointment['serviceend']&.to_time&.strftime('%Y-%m-%d'))
                if client_enrollment_service.present?
                  schedule = client_enrollment_service.schedulings.find_or_initialize_by(date: appointment['apptdate']&.to_time&.strftime('%Y-%m-%d'), start_time: appointment['appointmentstartdatetime']&.to_time&.strftime('%H:%M'), end_time: appointment['appointmentenddatetime']&.to_time&.strftime('%H:%M'))
                  # status
                  schedule.units = appointment['actualunits'].to_f
                  schedule.minutes = appointment['durationmins'].to_f
                  if appointment['isrendered']=='Yes'
                    schedule.status = 'Rendered'
                    schedule.is_rendered = true
                    schedule.rendered_at = appointment['renderedtime']&.to_datetime if appointment['renderedtime'].present?
                  else
                    case appointment['apptstatus']
                    when 'ACTIVE'
                      schedule.status = 'Scheduled'
                    when 'Non-Billable'
                      schedule.status = 'Non_Billable'
                    when 'Unavailable'
                      schedule.status = 'Unavailable'
                    when 'Staff Cancellation'
                      schedule.status = 'Staff_Cancellation'
                    when 'Client Cancel Less Than 24 Hours'
                      schedule.status = 'Client_Cancel_Less_than_24_h'
                    when 'Client Cancel Greater Than 24 Hours'
                      schedule.status = 'Client_Cancel_Greater_than_24_h'
                    when 'Inclement Weather Cancellation'
                      schedule.status = 'Inclement_Weather_Cancellation'
                    when 'Client No Show'
                      schedule.status = 'Client_No_Show'
                    end
                  end 
                  staff = Staff.find_by(email: appointment['staffemail'])
                  schedule.staff_id = staff.id
                  creator_name = appointment['apptcreator']&.split(',')&.each(&:strip!)
                  schedule.creator_id = Staff.find_by(first_name: creator_name.last, last_name: creator_name.first)&.id
                  schedule.cross_site_allowed = true if appointment['crossofficeappt'].present? && appointment['crossofficeappt'].split('/').count>1
                  schedule.service_address_id = client.addresses.by_service_address.find_by(city: appointment['clientcity'], zipcode: appointment['clientzip'])
                  schedule.save(validate: false)
                end
              end
            end
          end
        end
      end

      def get_funding_source(funding_source_name)
        case funding_source_name
        when 'BCBS NH'
          return FundingSource.find_by(name: 'New Hampshire BCBS').id
        when 'AMBETTER NNHF'
          return FundingSource.find_by(name: 'Ambetter nnhf').id
        when 'AETNA'
          return FundingSource.find_by(name: 'Aetna').id
        when 'OPTUM'
          return FundingSource.find_by(name: 'Optumhealth Behavioral Solutions').id
        when 'UBH'
          return FundingSource.find_by(name: 'United Behavioral Health').id
        when 'BHS'
          return FundingSource.find_by(name: 'Beacon health strategies').id
        when 'AMERIHEALTH'
          return FundingSource.find_by(name: 'Amerihealth caritas nh').id
        when 'CIGNA'
          return FundingSource.find_by(name: 'Cigna').id
        when 'TUFTS'
          return FundingSource.find_by(name: 'TUFTS').id
        when 'UMR'
          return FundingSource.find_by(name: 'UMR').id
        when 'HP'
          return FundingSource.find_by(name: 'Harvard pilgrim').id
        when 'aba'
          return FundingSource.find_by(name: 'ABA Centers of America').id
        when 'UNICARE'
          return FundingSource.find_by(name: 'Unicare').id
        when 'BEACON HEALTH OPTIONS'
          return FundingSource.find_by(name: 'Beacon Health Options').id
        when 'BCBS MA'
          return FundingSource.find_by(name: 'Massachusetts BCBS').id
        else 
          return nil
        end
      end
    end
  end
end
