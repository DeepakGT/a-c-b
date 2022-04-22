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

        client_data_array.each do |client_data|
          clients = Client.where(first_name: client_data['firstName'], last_name: client_data['lastName'], dob: client_data['dateOfBirth'])
          if clients.present?
            clients.each do |client|
              if client.catalyst_patient_id.blank?
                client.catalyst_patient_id = client_data['patientId']
                client.save(validate: false)
                break
              end
            end
          else
            client = Client.new(first_name: client_data['firstName'], last_name: client_data['lastName'], dob: client_data['dateOfBirth'], catalyst_patient_id: client_data['patientId'])
            client.status = 'inactive' if client_data['active'].to_bool.false?
            client.bcba_id = Staff.find_by(catalyst_user_id: client_data['bcba'])&.id
            client.clinic_id = Clinic.find_by(catalyst_clinic_id: client_data['siteId'])&.id
            client.gender = client_data['gender']==2 ? 1 : 0
            client.save(validate: false)
          end
        end
      end
    end
  end
end
