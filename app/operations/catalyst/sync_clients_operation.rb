module Catalyst
  module SyncClientsOperation
    class << self
      def call(start_date)
        sync_client_data(start_date)
      end

      private

      def sync_client_data(start_date)
        access_token = Catalyst::GetAccessTokenService.call
        client_data_array = Catalyst::PatientsApiService.call(start_date, access_token)

        client_data_array.each_index do |i|
          client_data = client_data_array[i]
          if (client_data['firstName']=='Denali' && client_data['lastName']=='Page' && client_data['dateOfBirth']&.strftime('%Y-%m-%d')=='2015-01-15') || (client_data['firstName']=='Milton' && client_data['lastName']=='Moye' && client_data['dateOfBirth']&.strftime('%Y-%m-%d')=='2018-06-20')
            if client_data['active'].to_bool.true?
              client = Client.find_by(first_name: client_data['firstName'], last_name: client_data['lastName'], dob: client_data['dateOfBirth']&.strftime('%Y-%m-%d'))
              if client.present?
                client.catalyst_patient_id = client_data['patientId']
                client.save(validate: false)
                Loggers::Catalyst::SyncStaffAndClientsLoggerService.call(i, "Client #{client_data['firstName']} #{client_data['lastName']} catalyst patient id is saved.")
              # else
              #   client = Client.new(first_name: client_data['firstName'], last_name: client_data['lastName'], dob: client_data['dateOfBirth'], catalyst_patient_id: client_data['patientId'])
              #   client.status = 'inactive' if client_data['active'].to_bool.false?
              #   client.bcba_id = Staff.find_by(catalyst_user_id: client_data['bcba'])&.id
              #   client.clinic_id = Clinic.find_by(catalyst_clinic_id: client_data['siteId'])&.id
              #   client.gender = client_data['gender']==2 ? 1 : 0
              #   client.save(validate: false)
              else
                Loggers::Catalyst::SyncStaffAndClientsLoggerService.call(i, "Client #{client_data['firstName']} #{client_data['lastName']} not found.")
              end
            end
          else
            if client_data['firstName']=='Alaiah' && client_data['lastName']=='Vasquez' && client_data['dateOfBirth']&.strftime('%Y-%m-%d')=='2018-02-22'
              client_data['lastName'] = 'Vazquez' 
            elsif client_data['firstName']=='Jayce' && client_data['lastName']=='Giles' && client_data['dateOfBirth']&.strftime('%Y-%m-%d')=='2016-12-18'
              client_data['lastName'] = 'Gilles'
            elsif client_data['firstName']=='Matthias' && client_data['lastName']=='Rumell Buss' && client_data['dateOfBirth']&.strftime('%Y-%m-%d')=='2004-09-24'
              client_data['lastName'] = 'Buss'
            elsif client_data['firstName']=='Maley' && client_data['lastName']=='Soucy' && client_data['dateOfBirth']&.strftime('%Y-%m-%d')=='2002-09-02'
              client_data['firstName'] = ' Malei'
              client_data['lastName'] = 'Lin-Yilan Soucy'
            end
            client = Client.find_by(first_name: client_data['firstName']&.strip, last_name: client_data['lastName']&.strip, dob: client_data['dateOfBirth']&.strftime('%Y-%m-%d'))
            if client.present?
              client.catalyst_patient_id = client_data['patientId']
              client.save(validate: false)
              Loggers::Catalyst::SyncStaffAndClientsLoggerService.call(i, "Client #{client_data['firstName']} #{client_data['lastName']} catalyst patient id is saved.")
            # else
            #   client = Client.new(first_name: client_data['firstName'], last_name: client_data['lastName'], dob: client_data['dateOfBirth'], catalyst_patient_id: client_data['patientId'])
            #   client.status = 'inactive' if client_data['active'].to_bool.false?
            #   client.bcba_id = Staff.find_by(catalyst_user_id: client_data['bcba'])&.id
            #   client.clinic_id = Clinic.find_by(catalyst_clinic_id: client_data['siteId'])&.id
            #   client.gender = client_data['gender']==2 ? 1 : 0
            #   client.save(validate: false)
            else
              Loggers::Catalyst::SyncStaffAndClientsLoggerService.call(i, "Client #{client_data['firstName']} #{client_data['lastName']} not found.")
            end
          end
        end
      end
    end
  end
end
