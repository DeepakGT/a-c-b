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
          client = Client.find_by(dob: student_service['clientdob']&.to_time&.strftime('%Y-%m-%d'), first_name: client_name&.first, last_name: client_name&.last)
          if client.present?
            client_enrollment = client.client_enrollments.find_or_initialize_by(enrollment_date: student_service['contractstartdate']&.to_time&.strftime('%Y-%m-%d'), terminated_on: student_service['contractenddate']&.to_time&.strftime('%Y-%m-%d'), insurance_id: student_service['authorizationnumber'], subscriber_name: student_service['clientname'], subscriber_dob: client&.dob)
            client_enrollment.relationship = 'self'
            client_enrollment.subscriber_phone = client&.phone_number&.number
            funding_source_id = get_funding_source(student_service['fundingsource'])
            if funding_source_id.present?
              client_enrollment.source_of_payment = 'insurance'
              client_enrollment.funding_source_id = funding_source_id
            elsif student_service['fundingsource']==nil
              client_enrollment.source_of_payment = 'self_pay'
            end
            client_enrollment.save(validate: false)
          end
        end
      end

      def get_funding_source(funding_source_name)
        case funding_source_name
        when 'NEW HAMPSHIRE BCBS'
          return FundingSource.find_by(name: 'New Hampshire BCBS').id
        when 'AMBETTER NNHF'
          return FundingSource.find_by(name: 'Ambetter nnhf').id
        when 'AETNA'
          return FundingSource.find_by(name: 'Aetna').id
        when 'OPTUMHEALTH BEHAVIORAL SOLUTIONS'
          return FundingSource.find_by(name: 'Optumhealth Behavioral Solutions').id
        when 'UNITED BEHAVIORAL HEALTH'
          return FundingSource.find_by(name: 'United Behavioral Health').id
        when 'BEACON HEALTH STRTEGIES'
          return FundingSource.find_by(name: 'Beacon health strategies').id
        when 'AMERIHEALTH CARITAS NH'
          return FundingSource.find_by(name: 'Amerihealth caritas nh').id
        when 'CIGNA'
          return FundingSource.find_by(name: 'Cigna').id
        when 'TUFTS'
          return FundingSource.find_by(name: 'TUFTS').id
        when 'UMR'
          return FundingSource.find_by(name: 'UMR').id
        when 'HARVARD PILGRIM'
          return FundingSource.find_by(name: 'Harvard pilgrim').id
        when 'ABA Centers of America'
          return FundingSource.find_by(name: 'ABA Centers of America').id
        when 'UNICARE'
          return FundingSource.find_by(name: 'Unicare').id
        when 'BEACON HEALTH OPTIONS'
          return FundingSource.find_by(name: 'Beacon Health Options').id
        else 
          return nil
        end
      end
    end
  end
end
