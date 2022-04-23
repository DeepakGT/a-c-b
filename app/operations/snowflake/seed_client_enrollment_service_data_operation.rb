module Snowflake
  module SeedClientEnrollmentServiceDataOperation
    class << self
      def call(username, password)
        seed_client_enrollment_service_data(username, password)
      end

      private

      def seed_client_enrollment_service_data(username, password)
        db = Snowflake::SetDatabaseAndWarehouseService.call(username, password)
        student_services = Snowflake::GetStudentServiceDataService.call(db)

        student_services.each do |student_service|
          client_name = student_service['CLIENTNAME']&.split(' ')
          client = Client.find_by(dob: student_service['CLIENTDOB']&.to_time&.strftime('%Y:%m:%d'), first_name: client_name.first, last_name: client_name.last)
          if client.present?
            if student_service['FUNDINGSOURCE'].present?
              funding_source = FundingSource.find_by('lower(name) = ?', student_service['FUNDINGSOURCE'].downcase)
              client_enrollment = client&.client_enrollments&.find_by(source_of_payment: 'insurance', funding_source_id: funding_source&.id, enrollment_date: student_service['SERVICEFUNDINGBEGIN']&.to_time&.strftime('%Y:%m:%d'), terminated_on: student_service['SERVICEFUNDINGEND']&.to_time&.strftime('%Y:%m:%d'))
            else
              client_enrollment = client&.client_enrollments&.find_by(source_of_payment: 'self_pay', enrollment_date: student_service['SERVICEFUNDINGBEGIN']&.to_time&.strftime('%Y:%m:%d'), terminated_on: student_service['SERVICEFUNDINGEND']&.to_time&.strftime('%Y:%m:%d'))
            end
            if client_enrollment.present?
              service = Service.where('lower(name) = ?',student_service['SERVICENAME'].downcase).first
              if service.present?
                client_enrollment_service = client_enrollment.client_enrollment_services.find_or_initialize_by(start_date: student_service['SERVICEFUNDINGBEGIN']&.to_time&.strftime('%Y:%m:%d'), end_date: student_service['SERVICEFUNDINGEND']&.to_time&.strftime('%Y:%m:%d'), service_id: service.id)
                client_enrollment_service.minutes = (student_service['CONTRACTEDHOURS'].to_f)*60
                client_enrollment_service.units = (student_service['CONTRACTEDHOURS'].to_f)*4
                client_enrollment_service.save(validate: false)
              end
            end
          end
        end
      end
    end
  end
end
