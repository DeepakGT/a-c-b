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
          if client_data['active'].to_bool.true?
            if client_data['firstName']=='Jayce' && client_data['lastName']=='Giles' && client_data['dateOfBirth']&.to_time&.strftime('%Y-%m-%d')=='2016-12-18'
              client_data['lastName'] = 'Gilles'
            elsif client_data['firstName']=='Maley' && client_data['lastName']=='Lin-Yilan Soucy' && client_data['dateOfBirth']&.to_time&.strftime('%Y-%m-%d')=='2002-09-02'
              client_data['firstName'] = ' Malei'
            elsif client_data['firstName']=='Finn' && client_data['lastName']=='Byrne' && client_data['dateOfBirth']&.to_time&.strftime('%Y-%m-%d')=='2009-07-20'
              client_data['firstName'] = 'Finn '
            end
            client = Client.find_by(first_name: client_data['firstName']&.strip, last_name: client_data['lastName']&.strip, dob: client_data['dateOfBirth']&.to_time&.strftime('%Y-%m-%d'))
            client = Client.find_by(first_name: client_data['firstName'], last_name: client_data['lastName'], dob: client_data['dateOfBirth']&.to_time&.strftime('%Y-%m-%d')) if (client_data['firstName']=='Olivia ' && client_data['lastName']=='Medard')
            if client.present?
              client.catalyst_patient_id = client_data['patientId']
              client.save(validate: false)
              Loggers::Catalyst::SyncStaffAndClientsLoggerService.call(i, "Client #{client_data['firstName']} #{client_data['lastName']} catalyst patient id is saved.")
            else
              Loggers::Catalyst::SyncStaffAndClientsLoggerService.call(i, "Client #{client_data['firstName']} #{client_data['lastName']} not found.")
            end
          end
        end
      end
    end
  end
end
