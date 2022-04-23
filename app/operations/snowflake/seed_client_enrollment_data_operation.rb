module Snowflake
  module SeedClientEnrollmentDataOperation
    class << self
      def call(username, password)
        seed_client_enrollment_data(username, password)
      end

      private

      def seed_client_enrollment_data(username, password)
        db = Snowflake::SetDatabaseAndWarehouseService.call(username, password)
        student_services = Snowflake::GetStudentServiceDataService.call(db)

        student_services.each do |student_service|
          client_name = student_service['CLIENTNAME']&.split(' ')
          client = Client.find_by(dob: student_service['CLIENTDOB']&.to_time&.strftime('%Y:%m:%d'), first_name: client_name.first, last_name: client_name.last)
          if client.present?
            client_enrollment = client.client_enrollments.find_or_initialize_by(enrollment_date: student_service['CONTRACTSTARTDATE']&.to_time&.strftime('%Y:%m:%d'), terminated_on: student_service['CONTRACTENDDATE']&.to_time&.strftime('%Y:%m:%d'), insurance_id: student_service['AUTHORIZATIONNUMBER'], subscriber_name: student_service['CLIENTNAME'], subscriber_dob: client&.dob)
            client_enrollment.relationship = 'self'
            client_enrollment.subscriber_phone = client&.phone_number&.number
            if student_service['FUNDINGSOURCE'].present?
              client_enrollment.source_of_payment = 'insurance'
              client_enrollment.funding_source_id = FundingSource.where('lower(name) = ?', student_service['FUNDINGSOURCE'].downcase)&.first&.id
            else
              client_enrollment.source_of_payment = 'self_pay'
            end
            client_enrollment.save(validate: false)
          end
        end
      end
    end
  end
end
