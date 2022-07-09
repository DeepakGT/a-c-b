module Catalyst
  module SyncClinicsOperation
    class << self
      def call
        sync_clinic_data
      end

      private

      def sync_clinic_data
        access_token = Catalyst::GetAccessTokenService.call
        clinic_data_array = Catalyst::ClinicsApiService.call(access_token)

        clinic_data_array.each_index do |i|
          clinic_data = clinic_data_array[i]
          clinic = Clinic.find_by(name: clinic_data['name'])
          clinic = Clinic.find_by(name: 'Porthsmouth, NH') if clinic_data['name'] == 'Portsmouth, NH'
          if clinic.present?
            clinic.catalyst_clinic_id = clinic_data['siteId']
            clinic.save(validate: false)
            Loggers::Catalyst::SyncStaffAndClientsLoggerService.call(i, "#{clinic_data['name']} catalyst_clinic_id is saved.")
          else
            Loggers::Catalyst::SyncStaffAndClientsLoggerService.call(i, "Clinic #{clinic_data['name']} not found.")
          end
        end
      end
    end
  end
end
