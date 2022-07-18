require 'csv'
module CsvImport
  module SeedMissingAppointmentsOperation
    class << self
      def call(clinic_id, file_path)
        seed_missing_appointments(file_path)
      end
    
      private
      
      def seed_missing_appointments(file_path)
        CSV.foreach(Rails.root.join("#{file_path}"), headers: true, header_converters: :symbol) do |appointment|
          client = Client.where(first_name: appointment[:first_name], last_name: appointment[:last_name])
          if client.count>1
            client = client.find_by(status: 'active')
          else
            client = client.first
          end
          if client.present?
            authorization = ClientEnrollmentService.by_client(client.id).find_by(service_number: appointment[:authorizationnumber])
            if authorization.present?
              staff = Staff.find_by('lower(email) = ?', appointment[:staffemail]&.downcase)
              if staff.blank?
                staff_name = appointment[:staffname]&.split(',')&.each(&:strip!)
                staff = Staff.find_by(first_name: staff_name&.last, last_name: staff_name&.first)
              end
              if staff.present?
                schedule = Scheduling.find_or_initialize_by(snowflake_appointment_id: appointment[:appointmentid])
                schedule.client_enrollment_service_id = authorization.id
                schedule.staff_id = staff.id
                schedule.date = appointment[:apptdate]&.to_time&.strftime('%Y-%m-%d')
                schedule.start_time = appointment[:appointmentstartdatetime]&.to_time&.strftime('%H:%M')
                schedule.end_time = appointment[:appointmentenddatetime]&.to_time&.strftime('%H:%M')
                schedule.units = appointment[:npaw_units]
                schedule.minutes = appointment[:npaw_minutes]
                # schedule.minutes = appointment[:durationmins].to_f
                # rem = schedule.minutes%15
                # if rem == 0
                #   schedule.units = schedule.minutes/15
                # else
                #   if rem < 8
                #     schedule.units = (schedule.minutes - rem)/15
                #   else
                #     schedule.units = (schedule.minutes + 15 - rem)/15
                #   end
                # end 
                if appointment[:isrendered]=='Yes'
                  schedule.status = 'Rendered'
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
                # creator_name = appointment[:apptcreator]&.split(',')&.each(&:strip!)
                # schedule.creator_id = Staff.find_by(first_name: creator_name.last, last_name: creator_name.first)&.id
                schedule.cross_site_allowed = true if appointment[:crossofficeappt].present? && appointment[:crossofficeappt].split('/').count>1
                # schedule.service_address_id = client.addresses&.by_service_address&.find_by(city: appointment[:clientcity], zipcode: appointment[:clientzip])&.id
                schedule.save(validate: false)
                if schedule.id==nil
                  Loggers::MissingAppointmentsLoggerService.call(appointment[:appointmentid], 'Schedule cannot be saved.')
                else
                  Loggers::MissingAppointmentsLoggerService.call(appointment[:appointmentid], 'Schedule is saved.')
                end
              else
                Loggers::MissingAppointmentsLoggerService.call(appointment[:appointmentid], "Staff with email #{appointment[:staffemail]} and name #{appointment[:staffname]} cannot be found.")
              end
            else
              Loggers::MissingAppointmentsLoggerService.call(appointment[:appointmentid], "Client enrollment service with authorization number #{appointment[:authorizationnumber]} not found.")
            end
          else
            Loggers::MissingAppointmentsLoggerService.call(appointment[:appointmentid], "Client #{appointment[:first_name]} #{appointment[:last_name]} not found.")
          end
        end        
      end
    end
  end
end
