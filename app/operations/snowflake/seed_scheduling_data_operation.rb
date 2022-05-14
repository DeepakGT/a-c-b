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
        initial_count = Scheduling.count
        Loggers::SnowflakeSchedulingLoggerService.call(appointments.count, "Got #{appointments.count} from snowflake.")
        
        appointments.each do |appointment|
          appointment = appointment.with_indifferent_access
          client_name = appointment['clientname']&.split(',')&.each(&:strip!)
          client = Client.find_by(dob: appointment['clientdob']&.to_time&.strftime('%Y-%m-%d'), first_name: client_name&.last, last_name: client_name&.first)
          if client.present?
            funding_source_id = get_funding_source(appointment['fundingsource'], client)
            if funding_source_id.blank? && appointment['fundingsource'].present?
              Loggers::SnowflakeSchedulingLoggerService.call(appointments.find_index(appointment), "#{appointment['fundingsource']} funding source not found.")
            end
            if appointment['authorizationnumber'].present?
              client_enrollment = ClientEnrollment.find_by(insurance_id: appointment['authorizationnumber'])
              if client_enrollment.blank?
                if funding_source_id.present?
                  client_enrollment = client.client_enrollments.new(funding_source_id: funding_source_id, enrollment_date: appointment['servicestart'], terminated_on: appointment['serviceend'], insurance_id: appointment['authorizationnumber'])
                  client_enrollment.save(validate: false)
                  Loggers::SnowflakeSchedulingLoggerService.call(appointments.find_index(appointment), "Created new client_enrollment #{client_enrollment.id}")
                else
                  client_enrollment = client.client_enrollments.new(source_of_payment: 'self_pay', enrollment_date: appointment['servicestart'], terminated_on: appointment['serviceend'], insurance_id: appointment['authorizationnumber'])
                  client_enrollment.save(validate: false)
                  Loggers::SnowflakeSchedulingLoggerService.call(appointments.find_index(appointment), "Created new client_enrollment #{client_enrollment.id}")
                end
              end
            else
              if funding_source_id.present?
                client_enrollments = client&.client_enrollments&.where('funding_source_id = ?', funding_source_id)
                if client_enrollments.blank?
                  client_enrollment = client.client_enrollments.new(funding_source_id: funding_source_id, enrollment_date: appointment['servicestart'], terminated_on: appointment['serviceend'], source_of_payment: 'insurance')
                  client_enrollment.save(validate: false)
                  Loggers::SnowflakeSchedulingLoggerService.call(appointments.find_index(appointment), "Created new client_enrollment #{client_enrollment.id}")
                end
              else
                client_enrollment = client&.client_enrollments&.find_by(source_of_payment: 'self_pay')
                if client_enrollment.blank?
                  client_enrollment = client.client_enrollments.new(source_of_payment: 'self_pay', enrollment_date: appointment['servicestart'], terminated_on: appointment['serviceend'])
                  client_enrollment.save(validate: false)
                  Loggers::SnowflakeSchedulingLoggerService.call(appointments.find_index(appointment), "Created new client_enrollment #{client_enrollment.id}")
                end
              end
            end
            # if funding_source_id.present?
            #   if appointment['authorizationnumber'].present?
            #     # client_enrollments = client&.client_enrollments&.where(funding_source_id: funding_source_id, insurance_id: appointment['authorizationnumber'])
            #     client_enrollments = client&.client_enrollments&.where(insurance_id: appointment['authorizationnumber'])
            #   else
            #     client_enrollments = client&.client_enrollments&.where('funding_source_id = ?', funding_source_id)
            #   end
            # elsif appointment['fundingsource']==nil
            #   if appointment['authorizationnumber'].present?
            #     # client_enrollments = client&.client_enrollments&.find_by(source_of_payment: 'self_pay', insurance_id: appointment['authorizationnumber'])
            #     client_enrollments = client&.client_enrollments&.find_by(insurance_id: appointment['authorizationnumber'])
            #     if client_enrollments.blank? && appointment['servicename'].present?
            #       client_enrollment = client.client_enrollments.new(source_of_payment: 'self_pay', enrollment_date: appointment['servicestart'], terminated_on: appointment['serviceend'], insurance_id: appointment['authorizationnumber'])
            #       client_enrollment.save(validate: false)
            #       client_enrollments = client&.client_enrollments&.where(source_of_payment: 'self_pay', insurance_id: appointment['authorizationnumber']).reload
            #       Loggers::SnowflakeSchedulingLoggerService.call(appointments.find_index(appointment), "Created new client_enrollment #{client_enrollment.id}")
            #     end
            #   else
            #     client_enrollments = client&.client_enrollments&.find_by(source_of_payment: 'self_pay')
            #     if client_enrollments.blank? && appointment['servicename'].present?
            #       client_enrollment = client.client_enrollments.new(source_of_payment: 'self_pay', enrollment_date: appointment['servicestart'], terminated_on: appointment['serviceend'])
            #       client_enrollment.save(validate: false)
            #       client_enrollments = client&.client_enrollments&.where(source_of_payment: 'self_pay').reload
            #       Loggers::SnowflakeSchedulingLoggerService.call(appointments.find_index(appointment), "Created new client_enrollment #{client_enrollment.id}")
            #     end
            #   end
            # end
            # if client_enrollments.blank? && appointment['servicename'].present?
            #   if appointment['authorizationnumber'].present?
            #     client_enrollment = client.client_enrollments.new(funding_source_id: funding_source_id, enrollment_date: appointment['servicestart'], terminated_on: appointment['serviceend'], insurance_id: appointment['authorizationnumber'])
            #     client_enrollment.save(validate: false)
            #     client_enrollments = client&.client_enrollments&.where(funding_source_id: funding_source_id, insurance_id: appointment['authorizationnumber']).reload
            #     Loggers::SnowflakeSchedulingLoggerService.call(appointments.find_index(appointment), "Created new client_enrollment #{client_enrollment.id}")
            #   else
            #     client_enrollment = client.client_enrollments.new(funding_source_id: funding_source_id, enrollment_date: appointment['servicestart'], terminated_on: appointment['serviceend'])
            #     client_enrollment.save(validate: false)
            #     client_enrollments = client&.client_enrollments&.where('funding_source_id = ?', funding_source_id).reload
            #     Loggers::SnowflakeSchedulingLoggerService.call(appointments.find_index(appointment), "Created new client_enrollment #{client_enrollment.id}")
            #   end
            # end
            # if client_enrollments.present?
            if client_enrollments.present? || client_enrollment.present?
              service = Service.where('lower(name) = ?', appointment['servicename']&.downcase).first
              if service.present?
                if client_enrollments.present?
                  client_enrollment_service = ClientEnrollmentService.where(client_enrollment_id: client_enrollments.pluck(:id))&.find_by(service_id: service.id, start_date: appointment['servicestart'], end_date: appointment['serviceend'])
                elsif client_enrollment.present?
                  client_enrollment_service = ClientEnrollmentService.where(client_enrollment_id: client_enrollment.id).find_by(service_id: service.id, start_date: appointment['servicestart'], end_date: appointment['serviceend'])
                end
                if client_enrollment_service.blank?
                  if client_enrollments.present?
                    client_enrollment_service = ClientEnrollmentService.where(client_enrollment_id: client_enrollments.pluck(:id))&.find_by(service_id: service.id)
                  elsif client_enrollment.present?
                    client_enrollment_service = ClientEnrollmentService.where(client_enrollment_id: client_enrollment.id)&.find_by(service_id: service.id)
                  end
                end
                if client_enrollment_service.blank?
                  client_enrollment_service = ClientEnrollmentService.new
                  if client_enrollments.present?
                    # client_enrollment_service = client_enrollments.first.client_enrollment_services.new(service_id: service.id, start_date: appointment['servicestart'], end_date: appointment['serviceend'])
                    client_enrollment_service.client_enrollment_id = client_enrollments.first.id
                  elsif client_enrollment.present?
                    # client_enrollment_service = client_enrollment.client_enrollment_services.new(service_id: service.id, start_date: appointment['servicestart'], end_date: appointment['serviceend'])
                    client_enrollment_service.client_enrollment_id = client_enrollment.id
                  end
                  client_enrollment_service.service_id = service.id
                  client_enrollment_service.start_date =  appointment['servicestart']
                  client_enrollment_service.end_date =  appointment['serviceend']
                  client_enrollment_service.save(validate: false)
                  Loggers::SnowflakeSchedulingLoggerService.call(appointments.find_index(appointment), "Created new client_enrollment service #{client_enrollment_service.id}")
                end
                if client_enrollment_service.present?
                  staff = Staff.find_by('lower(email) = ?', appointment['staffemail']&.downcase)
                  if staff.blank?
                    staff_name = appointment['staffname']&.split(',')&.each(&:strip!)
                    staff = Staff.find_by(first_name: staff_name&.last, last_name: staff_name&.first)
                  end
                  if staff.present?
                    schedule = Scheduling.find_or_initialize_by(snowflake_appointment_id: appointment['appointmentid'])
                    schedule.client_enrollment_service_id = client_enrollment_service.id
                    schedule.date = appointment['apptdate']&.to_time&.strftime('%Y-%m-%d')
                    schedule.start_time = appointment['appointmentstartdatetime']&.to_time&.strftime('%H:%M')
                    schedule.end_time = appointment['appointmentenddatetime']&.to_time&.strftime('%H:%M')
                    schedule.staff_id = staff.id
                    # schedule = client_enrollment_service.schedulings.find_or_initialize_by(date: appointment['apptdate']&.to_time&.strftime('%Y-%m-%d'), start_time: appointment['appointmentstartdatetime']&.to_time&.strftime('%H:%M'), end_time: appointment['appointmentenddatetime']&.to_time&.strftime('%H:%M'), staff_id: staff.id)
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
                    schedule.staff_id = staff.id
                    creator_name = appointment['apptcreator']&.split(',')&.each(&:strip!)
                    schedule.creator_id = Staff.find_by(first_name: creator_name.last, last_name: creator_name.first)&.id
                    schedule.cross_site_allowed = true if appointment['crossofficeappt'].present? && appointment['crossofficeappt'].split('/').count>1
                    schedule.service_address_id = client.addresses.by_service_address.find_by(city: appointment['clientcity'], zipcode: appointment['clientzip'])
                    schedule.save(validate: false)
                    if schedule.id==nil
                      Loggers::SnowflakeSchedulingLoggerService.call(appointments.find_index(appointment), 'Schedule cannot be saved.')
                    else
                      Loggers::SnowflakeSchedulingLoggerService.call(appointments.find_index(appointment), 'Schedule is saved.')
                    end
                  else
                    Loggers::SnowflakeSchedulingLoggerService.call(appointments.find_index(appointment), 'Staff not found.')
                  end
                else
                  Loggers::SnowflakeSchedulingLoggerService.call(appointments.find_index(appointment), 'Client enrollment service not found.')
                end
              else
                Loggers::SnowflakeSchedulingLoggerService.call(appointments.find_index(appointment), "#{appointment['servicename']} service not found.")
              end
            else
              Loggers::SnowflakeSchedulingLoggerService.call(appointments.find_index(appointment), "Client enrollment not found.")
            end
          else
            Loggers::SnowflakeSchedulingLoggerService.call(appointments.find_index(appointment), 'Client not found.')
          end
        end
        final_count = Scheduling.count
        seed_count = final_count - initial_count
        Loggers::SnowflakeSchedulingLoggerService.call(seed_count, "#{seed_count} schedulings seeded.")
      end

      def get_funding_source(funding_source_name,client)
        case funding_source_name
        when 'BCBS NH'
          return FundingSource.find_by(name: 'New Hampshire BCBS').id
        when 'AMBETTER NNHF', 'AMBETTER NHHF', 'AMBETTER NHHF '
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
        when 'BCBS MA', 'massachusetts bcbs', 'MASSACHUSETTS BCBS'
          return FundingSource.find_by(name: 'Massachusetts BCBS').id
        when 'Humana'
          funding_source = FundingSource.find_by(name: 'humana')
          return funding_source&.id
        when 'BCBSNJ'
          funding_source = FundingSource.find_by(name: 'BCBS New Jersey')
          return funding_source&.id
        when 'BCBS FL'
          funding_source = FundingSource.find_by(name: 'bcbsfl')
          return funding_source&.id
        when 'COMPSYCH'
          funding_source = FundingSource.find_by(name: 'compsych')
          return funding_source&.id
        else 
          return nil
        end
      end
    end
  end
end
