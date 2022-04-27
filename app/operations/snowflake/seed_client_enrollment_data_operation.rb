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
          student_service = student_service.with_indifferent_access
          client_name = student_service['clientname']&.split(' ')
          client = Client.find_by(dob: student_service['clientdob']&.to_time&.strftime('%Y:%m:%d'), first_name: client_name&.first, last_name: client_name&.last)
          if client.present?
            client_enrollment = client.client_enrollments.find_or_initialize_by(enrollment_date: student_service['contractstartdate']&.to_time&.strftime('%Y:%m:%d'), terminated_on: student_service['contractenddate']&.to_time&.strftime('%Y:%m:%d'), insurance_id: student_service['authorizationnumber'], subscriber_name: student_service['clientname'], subscriber_dob: client&.dob)
            client_enrollment.relationship = 'self'
            client_enrollment.subscriber_phone = client&.phone_number&.number
            if student_service['fundingsource'].present?
              client_enrollment.source_of_payment = 'insurance'
              client_enrollment.funding_source_id = FundingSource.where('lower(name) = ?', student_service['fundingsource'].downcase)&.first&.id
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
