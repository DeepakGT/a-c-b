require 'csv'
module CsvImport
  module SeedMissingAppointmentsOperation
    class << self
      def call(file_path)
        seed_missing_appointments(file_path)
      end
    
      private
      
      def seed_missing_appointments(file_path)
        CSV.foreach(Rails.root.join("#{file_path}"), headers: true, header_converters: :symbol) do |appointment|
          client_name = appointment[:clientname]&.split(',')&.each(&:strip!)
          case appointment[:clientname]
          when 'James, Francis Franky' 
            client_name[1] = 'Francis'
          when 'Buss, Matthias Rumell'
            client_name[1] = 'Matthias'
          when 'Anderson, Robert RJ'
            client_name[1] = 'Robert'
          end
          if client_name.present?
            if appointment[:clientname]=='Syed Abraham Hasan' || appointment[:clientname]=='Syed Adam Hasan' || appointment[:clientname]=='Ana Clara El-Gamel'
              client_name[2] = "#{client_name[1]} #{client_name[2]}"
              # client_name[1] = "#{client_name[2]}"
            elsif client_name.count==3
              client_name[0] = "#{client_name[0]} #{client_name[1]}"
            elsif client_name.count==4
              client_name[0] = "#{client_name[0]} #{client_name[1]} #{client_name[2]}"
            elsif client_name.count==5
              client_name[0] = "#{client_name[0]} #{client_name[1]} #{client_name[2]} #{client_name[3]}"
            end
            client = Client.where(first_name: client_name&.last, last_name: client_name&.first)
            if client.count>1
              client = client.find_by(status: 'active')
            else
              client = client.first
            end
          end
          if appointment[:clientname]=='Tanay Toth, Peter '
            client = Client.find(1894)
          end
          if client.present?
            # authorization = ClientEnrollmentService.by_client(client.id).where('start_date<=? AND end_date<=?', appointment[:apptdate]&.to_time&.strftime('%Y-%m-%d'), appointment[:apptdate]&.to_time&.strftime('%Y-%m-%d'))
            # if authorization.present?
            #   staff = Staff.find_by('lower(email) = ?', appointment[:staffemail]&.downcase)
            #   if staff.blank?
            #     staff_name = appointment[:staffname]&.split(',')&.each(&:strip!)
            #     staff = Staff.find_by(first_name: staff_name&.last, last_name: staff_name&.first)
            #   end
            #   if staff.present?
            #     schedule = Scheduling.find_or_initialize_by(snowflake_appointment_id: appointment[:appointmentid])
            #     schedule.client_enrollment_service_id = authorization.id
            #     schedule.staff_id = staff.id
            #     schedule.date = appointment[:apptdate]&.to_time&.strftime('%Y-%m-%d')
            #     schedule.start_time = appointment[:appointmentstartdatetime]&.to_time&.strftime('%H:%M')
            #     schedule.end_time = appointment[:appointmentenddatetime]&.to_time&.strftime('%H:%M')
            #     schedule.units = appointment[:npaw_units]
            #     schedule.minutes = appointment[:npaw_minutes]
            #     # schedule.minutes = appointment[:durationmins].to_f
            #     # rem = schedule.minutes%15
            #     # if rem == 0
            #     #   schedule.units = schedule.minutes/15
            #     # else
            #     #   if rem < 8
            #     #     schedule.units = (schedule.minutes - rem)/15
            #     #   else
            #     #     schedule.units = (schedule.minutes + 15 - rem)/15
            #     #   end
            #     # end 
            #     if appointment[:isrendered]=='Yes'
            #       schedule.status = 'Rendered'
            #       schedule.rendered_at = appointment[:renderedtime]&.to_datetime if appointment[:renderedtime].present?
            #     else
            #       case appointment[:apptstatus]
            #       when 'ACTIVE'
            #         schedule.status = 'Scheduled'
            #       when 'Non-Billable'
            #         schedule.status = 'Non_Billable'
            #       when 'Unavailable'
            #         schedule.status = 'Unavailable'
            #       when 'Staff Cancellation'
            #         schedule.status = 'Staff_Cancellation'
            #       when 'Client Cancel Less Than 24 Hours'
            #         schedule.status = 'Client_Cancel_Less_than_24_h'
            #       when 'Client Cancel Greater Than 24 Hours'
            #         schedule.status = 'Client_Cancel_Greater_than_24_h'
            #       when 'Inclement Weather Cancellation'
            #         schedule.status = 'Inclement_Weather_Cancellation'
            #       when 'Client No Show'
            #         schedule.status = 'Client_No_Show'
            #       end
            #     end 
            #     # creator_name = appointment[:apptcreator]&.split(',')&.each(&:strip!)
            #     # schedule.creator_id = Staff.find_by(first_name: creator_name.last, last_name: creator_name.first)&.id
            #     schedule.cross_site_allowed = true if appointment[:crossofficeappt].present? && appointment[:crossofficeappt].split('/').count>1
            #     # schedule.service_address_id = client.addresses&.by_service_address&.find_by(city: appointment[:clientcity], zipcode: appointment[:clientzip])&.id
            #     schedule.save(validate: false)
            #     if schedule.id==nil
            #       Loggers::MissingAppointmentsLoggerService.call(appointment[:appointmentid], 'Schedule cannot be saved.')
            #     else
            #       Loggers::MissingAppointmentsLoggerService.call(appointment[:appointmentid], 'Schedule is saved.')
            #     end
            #   else
            #     Loggers::MissingAppointmentsLoggerService.call(appointment[:appointmentid], "Staff with email #{appointment[:staffemail]} and name #{appointment[:staffname]} cannot be found.")
            #   end
            # else
            #   Loggers::MissingAppointmentsLoggerService.call(appointment[:appointmentid], "Client enrollment service with authorization number #{appointment[:authorizationnumber]} not found.")
            # end
            if appointment[:ss_fundingsource].present?
              funding_source_id = get_funding_source(appointment[:ss_fundingsource])
              if funding_source_id.present?
                service = Service.where('lower(name) = ?', appointment[:servicename]&.downcase).first
                # if appointment[:servicename]=='Supervision'
                #   service = Service.find(17)
                # end
                if service.present?
                  client_enrollment_services = ClientEnrollmentService.by_client(client.id).by_funding_source(funding_source_id).by_service(service.id).by_date(appointment[:apptdate]&.to_time&.strftime('%Y-%m-%d'))
                  if client_enrollment_services.present?
                    if client_enrollment_services.count==1
                      client_enrollment_service = client_enrollment_services.first
                    elsif client_enrollment_services.count>1
                      client_enrollment_services = client_enrollment_services.where('start_date <= ? AND end_date>=?', appointment[:servicestart]&.to_time&.strftime('%Y-%m-%d'), appointment[:serviceend]&.to_time&.strftime('%Y-%m-%d'))
                      if client_enrollment_services.count==1
                        client_enrollment_service = client_enrollment_services.first
                      else
                        client_enrollment_services.each do |authorization|
                          if authorization.left_units >= appointment[:actualunits].to_f
                            client_enrollment_service = authorization
                            break
                          end
                        end
                      end
                    else
                      client_enrollment_services = ClientEnrollmentService.by_client(client.id).by_funding_source(funding_source_id).by_service(service.id).by_date(appointment[:apptdate]&.to_time&.strftime('%Y-%m-%d'))
                      client_enrollment_service = client_enrollment_services.first
                    end
                    staff = Staff.find_by('lower(email) = ?', appointment[:staffemail]&.downcase)
                    if staff.blank?
                      staff_name = appointment[:staffname]&.split(',')&.each(&:strip!)
                      staff = Staff.find_by(first_name: staff_name&.last, last_name: staff_name&.first)
                    end
                    if staff.present?
                      create_scheduling(appointment, client_enrollment_service, staff, client, appointment[:appointmentid])
                    else
                      Loggers::MissingAppointmentsLoggerService.call(appointment[:appointmentid], "Staff #{appointment[:staffname]} not found.")
                    end
                  else
                    Loggers::MissingAppointmentsLoggerService.call(appointment[:appointmentid], "Client enrollment service not found.")
                  end
                else
                  Loggers::MissingAppointmentsLoggerService.call(appointment[:appointmentid], "#{appointment[:servicename]} service not found.")
                end
              else
                Loggers::MissingAppointmentsLoggerService.call(appointment[:appointmentid], "#{appointment[:fundingsource]} funding source not found.")
              end
            else
              #self_pay
              service = Service.where('lower(name) = ?', appointment[:servicename]&.downcase).first
              # if appointment[:servicename]=='Supervision'
              #   service = Service.find(17)
              # end
              if service.present?
                client_enrollment_services = ClientEnrollmentService.by_client(client.id).where('client_enrollments.source_of_payment = ?', 'self_pay').by_service(service.id).by_date(appointment[:apptdate]&.to_time&.strftime('%Y-%m-%d'))
                if client_enrollment_services.present?
                  if client_enrollment_services.count==1
                    client_enrollment_service = client_enrollment_services.first
                  else
                    client_enrollment_services = client_enrollment_services.where('start_date <= ? AND end_date>=?', appointment[:servicefundingbegin]&.to_time&.strftime('%Y-%m-%d'), appointment[:servicefundingend]&.to_time&.strftime('%Y-%m-%d'))
                    if client_enrollment_services.count==1
                      client_enrollment_service = client_enrollment_services.first
                    else
                      client_enrollment_services.each do |authorization|
                        if authorization.left_units >= appointment[:actualunits].to_f
                          client_enrollment_service = authorization
                          break
                        end
                      end
                    end
                  end
                  staff = Staff.find_by('lower(email) = ?', appointment[:staffemail]&.downcase)
                  if staff.blank?
                    staff_name = appointment[:staffname]&.split(',')&.each(&:strip!)
                    staff = Staff.find_by(first_name: staff_name&.last, last_name: staff_name&.first)
                  end
                  if staff.present?
                    create_scheduling(appointment, client_enrollment_service, staff, client, appointment[:appointmentid])
                  else
                    Loggers::MissingAppointmentsLoggerService.call(appointment[:appointmentid], "Staff #{appointment[:staffname]} not found.")
                  end
                else
                  Loggers::MissingAppointmentsLoggerService.call(appointment[:appointmentid], "Client enrollment service not found.")
                end
              else
                Loggers::MissingAppointmentsLoggerService.call(appointment[:appointmentid], "#{appointment[:servicename]} service not found.")
              end
            end
          else
            Loggers::MissingAppointmentsLoggerService.call(appointment[:appointmentid], "Client #{appointment[:first_name]} #{appointment[:last_name]} not found.")
          end
        end        
      end

      def get_funding_source(funding_source_name)
        case funding_source_name
        when 'BCBS NH'
          return FundingSource.find_by(name: 'New Hampshire BCBS').id
        when 'AMBETTER NNHF', 'AMBETTER NHHF', 'AMBETTER NHHF '
          return FundingSource.find_by(name: 'Ambetter nnhf').id
        when 'AETNA'
          return FundingSource.find_by(name: 'Aetna').id
        when 'OPTUM', 'OPTUMHEALTH BEHAVIORAL SOLUTIONS'
          return FundingSource.find_by(name: 'Optum Health Behavioral Solutions').id
        when 'UBH', 'UNITED BEHAVIORAL HEALTH'
          return FundingSource.find_by(name: 'United Behavioral Health').id
        when 'BHS', 'BEACON HEALTH STRTEGIES'
          return FundingSource.find_by(name: 'Beacon health strategies (Duplicate-pending purge)').id
        when 'AMERIHEALTH', 'AMERIHEALTH CARITAS NH'
          return FundingSource.find_by(name: 'Amerihealth caritas nh').id
        when 'CIGNA'
          return FundingSource.find_by(name: 'Cigna').id
        when 'TUFTS'
          return FundingSource.find_by(name: 'TUFTS').id
        when 'UMR'
          return FundingSource.find_by(name: 'UMR').id
        when 'HP', 'HARVARD PILGRIM'
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

      def create_scheduling(appointment, client_enrollment_service, staff, client, appointment_id)
        schedule = Scheduling.find_or_initialize_by(snowflake_appointment_id: appointment_id)
        schedule.client_enrollment_service_id = client_enrollment_service.id
        schedule.staff_id = staff.id
        schedule.date = appointment[:apptdate]&.to_time&.strftime('%Y-%m-%d')
        schedule.start_time = appointment[:appointmentstartdatetime]&.to_time&.strftime('%H:%M')
        schedule.end_time = appointment[:appointmentenddatetime]&.to_time&.strftime('%H:%M')
        schedule.minutes = appointment[:durationmins].to_f
        rem = schedule.minutes%15
        if rem == 0
          schedule.units = schedule.minutes/15
        else
          if rem < 8
            schedule.units = (schedule.minutes - rem)/15
          else
            schedule.units = (schedule.minutes + 15 - rem)/15
          end
        end 
        if appointment[:isrendered]=='Yes'
          schedule.status = 'Rendered'
          # schedule.is_rendered = true
          schedule.rendered_at = appointment[:renderedtime]&.to_datetime if appointment[:renderedtime].present?
        else
          case appointment[:apptstatus]
          when 'ACTIVE'
            schedule.status = 'Scheduled'
          when 'Non-Billable'
            schedule.status = 'Non_Billable'
          when 'Unavailable'
            schedule.status = 'Unavailable'
          when 'Staff Cancellation'
            schedule.status = 'Staff_Cancellation due to illness'
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
        creator_name = appointment[:apptcreator]&.split(',')&.each(&:strip!)
        schedule.creator_id = Staff.find_by(first_name: creator_name.last, last_name: creator_name.first)&.id
        schedule.cross_site_allowed = true if appointment[:crossofficeappt].present? && appointment[:crossofficeappt].split('/').count>1
        schedule.service_address_id = client.addresses&.by_service_address&.find_by(city: appointment[:clientcity], zipcode: appointment[:clientzip])&.id
        schedule.id = Scheduling.last.id + 1
        schedule.save(validate: false)
        if schedule.id==nil
          Loggers::MissingAppointmentsLoggerService.call(appointment_id, 'Schedule cannot be saved.')
        else
          Loggers::MissingAppointmentsLoggerService.call(appointment_id, 'Schedule is saved.')
        end
      end
    end
  end
end
