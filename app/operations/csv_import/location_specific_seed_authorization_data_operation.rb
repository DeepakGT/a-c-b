require 'csv'
module CsvImport
  module LocationSpecificSeedAuthorizationDataOperation
    class << self
      def call(clinic_id, file_path)
        location_specific_seed_client_enrollment_service_data(clinic_id, file_path)
      end
    
      private

      def location_specific_seed_client_enrollment_service_data(clinic_id, file_path)
        clinic = Clinic.find(clinic_id)
        initial_count = ClientEnrollmentService.count
        count = 0
        i=0

        CSV.foreach(Rails.root.join("#{file_path}"), headers: true, header_converters: :symbol) do |student_service|
          i=i+1
          client_name = student_service[:clientname]&.split(' ')
          if student_service[:clientname]=='Syed Abraham Hasan' || student_service[:clientname]=='Syed Adam Hasan' || student_service[:clientname]=='Ana Clara El-Gamel'
            client_name[0] = "#{client_name[0]} #{client_name[1]}"
            client_name[1] = "#{client_name[2]}"
          elsif student_service[:clientname]=='Abdulhadi Mir'
            client_name[1] = '(Sultana)'
          elsif client_name.count==3
            client_name[1] = "#{client_name[1]} #{client_name[2]}"
          elsif client_name.count==4
            client_name[1] = "#{client_name[1]} #{client_name[2]} #{client_name[3]}"
          elsif client_name.count==5
            client_name[1] = "#{client_name[1]} #{client_name[2]} #{client_name[3]} #{client_name[4]}"
          end
          client = Client.find_by(dob: student_service[:clientdob]&.to_time&.strftime('%Y-%m-%d'), first_name: client_name&.first, last_name: client_name[1])
          if client.present? 
            count = count+1
            if client.clinic_id==clinic_id
              if student_service[:fundingsource].present?
                funding_source_id = get_funding_source(student_service[:fundingsource])
                if funding_source_id.present?
                  client_enrollment = client&.client_enrollments&.find_by(source_of_payment: 'insurance', funding_source_id: funding_source_id, enrollment_date: student_service[:contractstartdate]&.to_time&.strftime('%Y-%m-%d'), terminated_on: student_service[:contractenddate]&.to_time&.strftime('%Y-%m-%d'))
                  if client_enrollment.blank?
                    client_enrollment = client.client_enrollments.new(source_of_payment: 'insurance', funding_source_id: funding_source_id, enrollment_date: student_service[:contractstartdate]&.to_time&.strftime('%Y-%m-%d'), terminated_on: student_service[:contractenddate]&.to_time&.strftime('%Y-%m-%d'))
                    client_enrollment.save(validate: false)
                  end
                  if client_enrollment.present?
                    service = Service.where('lower(name) = ?',student_service[:servicename].downcase).first
                    service = Service.find(17) if student_service[:servicename]=='Supervision'
                    if service.present?
                      client_enrollment_service = client_enrollment.client_enrollment_services.find_or_initialize_by(start_date: student_service[:servicefundingbegin]&.to_time&.strftime('%Y-%m-%d'), end_date: student_service[:servicefundingend]&.to_time&.strftime('%Y-%m-%d'), service_id: service.id)
                      client_enrollment_service.service_number = student_service['authorizationnumber'] if student_service['authorizationnumber']!='No Auth Required'
                      client_enrollment_service.minutes = (student_service[:contractedhours].to_f)*60
                      rem = client_enrollment_service.minutes % 15
                      if rem==0
                        client_enrollment_service.units = client_enrollment_service.minutes / 15
                      elsif rem>=8
                        client_enrollment_service.units = (client_enrollment_service.minutes + 15 - rem) / 15
                      else
                        client_enrollment_service.units = (client_enrollment_service.minutes - rem) / 15
                      end
                      client_enrollment_service.save(validate: false)
                      if client_enrollment_service.id.nil?
                        Loggers::SnowflakeClientEnrollmentServiceLoggerService.call(i, 'Client enrollment service cannot be saved.')
                      else
                        Loggers::SnowflakeClientEnrollmentServiceLoggerService.call(i, 'Client enrollment service is saved.')
                      end
                    else
                      Loggers::SnowflakeClientEnrollmentServiceLoggerService.call(i, "#{student_service[:servicename]} service not found.")
                    end
                  else
                    Loggers::SnowflakeClientEnrollmentServiceLoggerService.call(i, "Client enrollment not found.")
                  end
                else
                  Loggers::SnowflakeClientEnrollmentServiceLoggerService.call(i, "#{student_service[:fundingsource]} funding source not found.")
                end
              else
                Loggers::SnowflakeClientEnrollmentServiceLoggerService.call(i, "#{student_service[:fundingsource]} is blank.")
                client_enrollment = client&.client_enrollments&.find_by(source_of_payment: 'self_pay', enrollment_date: student_service[:contractstartdate]&.to_time&.strftime('%Y-%m-%d'), terminated_on: student_service[:contractenddate]&.to_time&.strftime('%Y-%m-%d'))
                if client_enrollment.blank?
                  client_enrollment = client.client_enrollments.new(source_of_payment: 'self_pay', enrollment_date: student_service[:contractstartdate]&.to_time&.strftime('%Y-%m-%d'), terminated_on: student_service[:contractenddate]&.to_time&.strftime('%Y-%m-%d'))
                  client_enrollment.save(validate: false)
                end
                if client_enrollment.present?
                  service = Service.where('lower(name) = ?',student_service[:servicename].downcase).first
                  service = Service.find(17) if student_service[:servicename]=='Supervision'
                  if service.present?
                    client_enrollment_service = client_enrollment.client_enrollment_services.find_or_initialize_by(start_date: student_service[:servicefundingbegin]&.to_time&.strftime('%Y-%m-%d'), end_date: student_service[:servicefundingend]&.to_time&.strftime('%Y-%m-%d'), service_id: service.id)
                    client_enrollment_service.service_number = student_service['authorizationnumber'] if student_service['authorizationnumber']!='No Auth Required'
                    client_enrollment_service.minutes = (student_service[:contractedhours].to_f)*60
                    rem = client_enrollment_service.minutes % 15
                    if rem==0
                      client_enrollment_service.units = client_enrollment_service.minutes / 15
                    elsif rem>=8
                      client_enrollment_service.units = (client_enrollment_service.minutes + 15 - rem) / 15
                    else
                      client_enrollment_service.units = (client_enrollment_service.minutes - rem) / 15
                    end
                    client_enrollment_service.save(validate: false)
                    if client_enrollment_service.id.nil?
                      Loggers::SnowflakeClientEnrollmentServiceLoggerService.call(i, 'Client enrollment service cannot be saved.')
                    else
                      Loggers::SnowflakeClientEnrollmentServiceLoggerService.call(i, 'Client enrollment service is saved.')
                    end
                  else
                    Loggers::SnowflakeClientEnrollmentServiceLoggerService.call(i, "#{student_service[:servicename]} service not found.")
                  end
                else
                  Loggers::SnowflakeClientEnrollmentServiceLoggerService.call(i, "Client enrollment not found.")
                end
              end
            end
          else
            Loggers::SnowflakeClientEnrollmentServiceLoggerService.call(i, 'Client not found.')
          end
        end
        final_count = ClientEnrollmentService.count
        seed_count = final_count - initial_count
        Loggers::SnowflakeClientEnrollmentServiceLoggerService.call(i, "#{i} authorizations received.")
        Loggers::SnowflakeClientEnrollmentServiceLoggerService.call(count, "#{count} authorization of clinic #{clinic.name} must be seeded.")
        Loggers::SnowflakeClientEnrollmentServiceLoggerService.call(seed_count, "#{seed_count} authorization of clinic #{clinic.name} seeded.")
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
        when 'BCBS MA', 'massachusetts bcbs', 'MASSACHUSETTS BCBS'
          return FundingSource.find_by(name: 'Massachusetts BCBS').id
        else 
          if !funding_source_name.nil?
            funding_source = FundingSource.find_by('lower(name) = ?', funding_source_name&.downcase)
            return funding_source.id
          else
            return nil
          end
        end
      end
    end
  end
end
