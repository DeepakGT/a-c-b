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
          client_name = appointment['CLIENTNAME']&.split(',')&.each(&:strip!)
          client = Client.find_by(dob: appointment['CLIENTDOB']&.to_time&.strftime('%Y-%m-%d'), first_name: client_name.last, last_name: client_name.first)
          if client.present?
            if appointment['FUNDINGSOURCE'].present?
              funding_source = FundingSource.find_by('lower(name) = ?', appointment['FUNDINGSOURCE'].downcase)
              client_enrollment = client&.client_enrollments&.find_by(source_of_payment: 'insurance', funding_source_id: funding_source&.id, enrollment_date: appointment['SERVICEFUNDINGBEGIN']&.to_time&.strftime('%Y:%m:%d'), terminated_on: appointment['SERVICEFUNDINGEND']&.to_time&.strftime('%Y:%m:%d'))
            else
              client_enrollment = client&.client_enrollments&.find_by(source_of_payment: 'self_pay', enrollment_date: appointment['SERVICEFUNDINGBEGIN']&.to_time&.strftime('%Y:%m:%d'), terminated_on: appointment['SERVICEFUNDINGEND']&.to_time&.strftime('%Y:%m:%d'))
            end
            if client_enrollment.present?
              service = Service.where('lower(name) = ?',appointment['SERVICENAME'].downcase).first
              if service.present?
                client_enrollment_service = client_enrollment.client_enrollment_services.find_by(service_id: service.id, start_date: appointment['SERVICESTART']&.to_time&.strftime('%Y:%m:%d'), end_date: appointment['SERVICEEND']&.to_time&.strftime('%Y:%m:%d'))
                if client_enrollment_service.present?
                  schedule = client_enrollment_service.schedulings.find_or_initialize_by(date: appointment['APPTDATE']&.to_time&.strftime('%Y:%m:%d'), start_time: appointment['APPOINTMENTSTARTDATETIME']&.to_time&.strftime('%H:%M'), end_time: appointment['APPOINTMENTENDDATETIME']&.to_time&.strftime('%H:%M'))
                  # status
                  schedule.units = appointment['ACTUALUNITS'].to_f
                  schedule.minutes = appointment['DURATIONMINS'].to_f
                  if appointment['ISRENDERED']=='Yes'
                    schedule.status = 'Rendered'
                    schedule.is_rendered = true
                    schedule.rendered_at = appointment['RENDEREDTIME']&.to_datetime if appointment['RENDEREDTIME'].present?
                  else
                    case appointment['APPTSTATUS']
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
                  staff = Staff.find_by(email: appointment['STAFFEMAIL'])
                  schedule.staff_id = staff.id
                  creator_name = appointment['APPTCREATOR']&.split(',')&.each(&:strip!)
                  schedule.creator_id = Staff.find_by(first_name: creator_name.last, last_name: creator_name.first)&.id
                  schedule.cross_site_allowed = true if appointment['CROSSOFFICEAPPT'].present? && appointment['CROSSOFFICEAPPT'].split('/').count>1
                  schedule.service_address_id = client.addresses.by_service_address.find_by(city: appointment['CLIENTCITY'], zipcode: appointment['CLIENTZIP'])
                  schedule.save(validate: false)
                end
              end
            end
          end
        end
      end
    end
  end
end
