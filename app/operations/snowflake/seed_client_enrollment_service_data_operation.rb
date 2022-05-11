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
          student_service = student_service.with_indifferent_access
          client_name = student_service['clientname']&.split(' ')
          client = Client.find_by(dob: student_service['clientdob']&.to_time&.strftime('%Y-%m-%d'), first_name: client_name&.first, last_name: client_name&.last)
          if client.present?
            funding_source_id = get_funding_source(student_service['fundingsource'], client)
            if student_service['authorizationnumber'].present?
              if funding_source_id.present?
                client_enrollment = client&.client_enrollments&.find_by(source_of_payment: 'insurance', funding_source_id: funding_source_id, enrollment_date: student_service['servicefundingbegin']&.to_time&.strftime('%Y-%m-%d'), terminated_on: student_service['servicefundingend']&.to_time&.strftime('%Y-%m-%d'), insurance_id: student_service['authorizationnumber'])
              elsif student_service['fundingsource']==nil
                client_enrollment = client&.client_enrollments&.find_by(source_of_payment: 'self_pay', enrollment_date: student_service['servicefundingbegin']&.to_time&.strftime('%Y-%m-%d'), terminated_on: student_service['servicefundingend']&.to_time&.strftime('%Y-%m-%d'), insurance_id: student_service['authorizationnumber'])
              end
            else
              if funding_source_id.present?
                client_enrollment = client&.client_enrollments&.find_by(source_of_payment: 'insurance', funding_source_id: funding_source_id, enrollment_date: student_service['servicefundingbegin']&.to_time&.strftime('%Y-%m-%d'), terminated_on: student_service['servicefundingend']&.to_time&.strftime('%Y-%m-%d'))
              elsif student_service['fundingsource']==nil
                client_enrollment = client&.client_enrollments&.find_by(source_of_payment: 'self_pay', enrollment_date: student_service['servicefundingbegin']&.to_time&.strftime('%Y-%m-%d'), terminated_on: student_service['servicefundingend']&.to_time&.strftime('%Y-%m-%d'))
              end
            end
            if client_enrollment.present?
              service = Service.where('lower(name) = ?',student_service['servicename'].downcase).first
              if service.present?
                client_enrollment_service = client_enrollment.client_enrollment_services.find_or_initialize_by(start_date: student_service['contractstartdate']&.to_time&.strftime('%Y-%m-%d'), end_date: student_service['contractenddate']&.to_time&.strftime('%Y-%m-%d'), service_id: service.id)
                client_enrollment_service.minutes = (student_service['contractedhours'].to_f)*60
                client_enrollment_service.units = (student_service['contractedhours'].to_f)*4
                client_enrollment_service.save(validate: false)
                if client_enrollment_service.id==nil
                  Loggers::SnowflakeLoggerService.call(student_service, 'Client enrollment service cannot be saved.')
                end
              end
            end
          end
        end
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
        when 'BCBS MA' || 'massachusetts bcbs' || 'MASSACHUSETTS BCBS'
          return FundingSource.find_by(name: 'Massachusetts BCBS').id
        else 
          if funding_source_name!=nil
            funding_source = FundingSource.find_by('lower(name) = ?', funding_source_name&.downcase)
            if funding_source.blank?
              funding_source = FundingSource.new(name: funding_source_name&.downcase, clinic_id: client.clinic_id)
              funding_source.save(validate: false)
            end
            return funding_source.id
          else
            return nil
          end
        end
      end
    end
  end
end
