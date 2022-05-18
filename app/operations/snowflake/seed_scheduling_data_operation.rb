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
        
        appointments.each_index do |i|
          appointment = appointments[i]
          appointment = appointment.with_indifferent_access
          client_name = appointment['clientname']&.split(',')&.each(&:strip!)
          client = Client.find_by(dob: appointment['clientdob']&.to_time&.strftime('%Y-%m-%d'), first_name: client_name&.last, last_name: client_name&.first)
          if client.present?
            if appointment['fundingsource'].present?
              funding_source_id = get_funding_source(appointment['fundingsource'], client)
              if funding_source_id.present?
                service = Service.where('lower(name) = ?', appointment['servicename']&.downcase).first
                if service.present?
                  client_enrollment_services = ClientEnrollmentService.by_client(client.id).by_funding_source(funding_source_id).by_service(service.id).by_date(appointment['apptdate']&.to_time&.strftime('%Y-%m-%d'))
                  if client_enrollment_services.present?
                    if client_enrollment_services.count==1
                      client_enrollment_service = client_enrollment_services.first
                    else
                      client_enrollment_services = client_enrollment_services.where('start_date <= ? AND end_date>=?', appointment['servicestart']&.to_time&.strftime('%Y-%m-%d'), appointment['serviceend']&.to_time&.strftime('%Y-%m-%d'))
                      if client_enrollment_services.count==1
                        client_enrollment_service = client_enrollment_services.first
                      else
                        client_enrollment_services.each do |authorization|
                          # schedules = authorization.schedulings&.with_rendered_or_scheduled_as_status
                          # completed_schedules = schedules&.completed_scheduling
                          # scheduled_schedules = schedules&.scheduled_scheduling
                          # used_units = completed_schedules&.with_units&.pluck(:units)&.sum
                          # used_units = 0 if used_units.blank?
                          # scheduled_units = scheduled_schedules&.with_units&.pluck(:units)&.sum
                          # scheduled_units = 0 if scheduled_units.blank?
                          # left_units = authorization&.units - (used_units + scheduled_units)
                          if authorization.left_units >= appointment['actualunits'].to_f
                            client_enrollment_service = authorization
                            break
                          end
                        end
                      end
                    end
                    staff = Staff.find_by('lower(email) = ?', appointment['staffemail']&.downcase)
                    if staff.blank?
                      staff_name = appointment['staffname']&.split(',')&.each(&:strip!)
                      staff = Staff.find_by(first_name: staff_name&.last, last_name: staff_name&.first)
                    end
                    if staff.present?
                      schedule = Scheduling.find_or_initialize_by(snowflake_appointment_id: appointment['appointmentid'])
                      schedule.client_enrollment_service_id = client_enrollment_service.id
                      schedule.staff_id = staff.id
                      schedule.date = appointment['apptdate']&.to_time&.strftime('%Y-%m-%d')
                      schedule.start_time = appointment['appointmentstartdatetime']&.to_time&.strftime('%H:%M')
                      schedule.end_time = appointment['appointmentenddatetime']&.to_time&.strftime('%H:%M')
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
                      creator_name = appointment['apptcreator']&.split(',')&.each(&:strip!)
                      schedule.creator_id = Staff.find_by(first_name: creator_name.last, last_name: creator_name.first)&.id
                      schedule.cross_site_allowed = true if appointment['crossofficeappt'].present? && appointment['crossofficeappt'].split('/').count>1
                      schedule.service_address_id = client.addresses&.by_service_address&.find_by(city: appointment['clientcity'], zipcode: appointment['clientzip'])&.id
                      schedule.save(validate: false)
                      if schedule.id==nil
                        Loggers::SnowflakeSchedulingLoggerService.call(i, 'Schedule cannot be saved.')
                      else
                        Loggers::SnowflakeSchedulingLoggerService.call(i, 'Schedule is saved.')
                      end
                    else
                      Loggers::SnowflakeSchedulingLoggerService.call(i, "Staff #{appointment['staffname']} not found.")
                    end
                  else
                    Loggers::SnowflakeSchedulingLoggerService.call(i, "Client enrollment service not found.")
                  end
                else
                  Loggers::SnowflakeSchedulingLoggerService.call(i, "#{appointment['servicename']} service not found.")
                end
              else
                Loggers::SnowflakeSchedulingLoggerService.call(i, "#{appointment['fundingsource']} funding source not found.")
              end
            else
              #self_pay
              service = Service.where('lower(name) = ?', appointment['servicename']&.downcase).first
              if service.present?
                client_enrollment_services = ClientEnrollmentService.by_client(client.id).where('client_enrollments.source_of_payment = ?', 'self_pay').by_service(service.id).by_date(appointment['apptdate']&.to_time&.strftime('%Y-%m-%d'))
                if client_enrollment_services.present?
                  if client_enrollment_services.count==1
                    client_enrollment_service = client_enrollment_services.first
                  else
                    client_enrollment_services = client_enrollment_services.where('start_date <= ? AND end_date>=?', appointment['servicestart']&.to_time&.strftime('%Y-%m-%d'), appointment['serviceend']&.to_time&.strftime('%Y-%m-%d'))
                    if client_enrollment_services.count==1
                      client_enrollment_service = client_enrollment_services.first
                    else
                      client_enrollment_services.each do |authorization|
                        # schedules = authorization.schedulings&.with_rendered_or_scheduled_as_status
                        # completed_schedules = schedules&.completed_scheduling
                        # scheduled_schedules = schedules&.scheduled_scheduling
                        # used_units = completed_schedules&.with_units&.pluck(:units)&.sum
                        # used_units = 0 if used_units.blank?
                        # scheduled_units = scheduled_schedules&.with_units&.pluck(:units)&.sum
                        # scheduled_units = 0 if scheduled_units.blank?
                        # left_units = authorization&.units - (used_units + scheduled_units)
                        if authorization.left_units >= appointment['actualunits'].to_f
                          client_enrollment_service = authorization
                          break
                        end
                      end
                    end
                  end
                  staff = Staff.find_by('lower(email) = ?', appointment['staffemail']&.downcase)
                  if staff.blank?
                    staff_name = appointment['staffname']&.split(',')&.each(&:strip!)
                    staff = Staff.find_by(first_name: staff_name&.last, last_name: staff_name&.first)
                  end
                  if staff.present?
                    schedule = Scheduling.find_or_initialize_by(snowflake_appointment_id: appointment['appointmentid'])
                    schedule.client_enrollment_service_id = client_enrollment_service.id
                    schedule.staff_id = staff.id
                    schedule.date = appointment['apptdate']&.to_time&.strftime('%Y-%m-%d')
                    schedule.start_time = appointment['appointmentstartdatetime']&.to_time&.strftime('%H:%M')
                    schedule.end_time = appointment['appointmentenddatetime']&.to_time&.strftime('%H:%M')
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
                    creator_name = appointment['apptcreator']&.split(',')&.each(&:strip!)
                    schedule.creator_id = Staff.find_by(first_name: creator_name.last, last_name: creator_name.first)&.id
                    schedule.cross_site_allowed = true if appointment['crossofficeappt'].present? && appointment['crossofficeappt'].split('/').count>1
                    schedule.service_address_id = client.addresses&.by_service_address&.find_by(city: appointment['clientcity'], zipcode: appointment['clientzip'])&.id
                    schedule.save(validate: false)
                    if schedule.id==nil
                      Loggers::SnowflakeSchedulingLoggerService.call(i, 'Schedule cannot be saved.')
                    else
                      Loggers::SnowflakeSchedulingLoggerService.call(i, 'Schedule is saved.')
                    end
                  else
                    Loggers::SnowflakeSchedulingLoggerService.call(i, "Staff #{appointment['staffname']} not found.")
                  end
                else
                  Loggers::SnowflakeSchedulingLoggerService.call(i, "Client enrollment service not found.")
                end
              else
                Loggers::SnowflakeSchedulingLoggerService.call(i, "#{appointment['servicename']} service not found.")
              end
            end
          else
            Loggers::SnowflakeSchedulingLoggerService.call(i, 'Client not found.')
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
