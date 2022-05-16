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
        initial_count = ClientEnrollment.count
        Loggers::SnowflakeClientEnrollmentLoggerService.call(student_services.count, "Got #{student_services.count} services from snowflake.")

        student_services.each do |student_service|
          student_service = student_service.with_indifferent_access
          client_name = student_service['clientname']&.split(' ')
          if client_name.count==3
            client_name[1] = "#{client_name[1]} #{client_name[2]}"
          elsif client_name.count==4
            client_name[1] = "#{client_name[1]} #{client_name[2]} #{client_name[3]}"
          elsif client_name.count==5
            client_name[1] = "#{client_name[1]} #{client_name[2]} #{client_name[3]} #{client_name[4]}"
          end
          client = Client.find_by(dob: student_service['clientdob']&.to_time&.strftime('%Y-%m-%d'), first_name: client_name&.first, last_name: client_name[1])
          if client.present?
            if student_service['fundingsource'].present?
              funding_source_id = get_funding_source(student_service['fundingsource'], client)
              if funding_source_id.present?
                client_enrollment = client.client_enrollments.find_or_initialize_by(enrollment_date: student_service['contractstartdate']&.to_time&.strftime('%Y-%m-%d'), terminated_on: student_service['contractenddate']&.to_time&.strftime('%Y-%m-%d'), funding_source_id: funding_source_id)
                client_enrollment.source_of_payment = 'insurance'
                client_enrollment.save(validate: false)
                if client_enrollment.id==nil
                  Loggers::SnowflakeClientEnrollmentLoggerService.call(student_services.find_index(student_service), 'Client enrollment cannot be saved.')
                else
                  Loggers::SnowflakeClientEnrollmentLoggerService.call(student_services.find_index(student_service), 'Client enrollment is saved.')
                end
              else
                Loggers::SnowflakeClientEnrollmentLoggerService.call(student_services.find_index(student_service), "#{student_service['fundingsource']} funding source not found.")
              end
            else
              Loggers::SnowflakeClientEnrollmentLoggerService.call(student_services.find_index(student_service), 'Creating self_pay client_enrollment.')
              client_enrollment = client.client_enrollments.find_or_initialize_by(enrollment_date: student_service['contractstartdate']&.to_time&.strftime('%Y-%m-%d'), terminated_on: student_service['contractenddate']&.to_time&.strftime('%Y-%m-%d'), source_of_payment: 'self_pay')
              client_enrollment.save(validate: false)
              if client_enrollment.id==nil
                Loggers::SnowflakeClientEnrollmentLoggerService.call(student_services.find_index(student_service), 'Client enrollment cannot be saved.')
              else
                Loggers::SnowflakeClientEnrollmentLoggerService.call(student_services.find_index(student_service), 'Client enrollment is saved.')
              end
            end
          else
            Loggers::SnowflakeClientEnrollmentLoggerService.call(student_services.find_index(student_service), 'Client not found.')
          end
        end
        final_count = ClientEnrollment.count
        seed_count = final_count - initial_count
        Loggers::SnowflakeClientEnrollmentLoggerService.call(seed_count, "Seeded #{seed_count} in our database.")
      end

      def get_funding_source(funding_source_name, client)
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
        when 'MASSACHUSETTS BCBS'
          return FundingSource.find_by(name: 'Massachusetts BCBS').id
        else 
          if funding_source_name!=nil
            funding_source = FundingSource.where('lower(name) = ?', funding_source_name&.downcase).first
            return funding_source.id
          else
            return nil
          end
        end
      end
    end
  end
end
