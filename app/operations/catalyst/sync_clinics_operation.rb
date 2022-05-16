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

        clinic_data_array.each do |clinic_data|
          clinic = Clinic.find_by(name: clinic_data['name'])
          if clinic_data['name'] == 'Portsmouth, NH'
            clinic = Clinic.find_by(name: 'Porthsmouth, NH')
          end
          
          if clinic.present?
            clinic.catalyst_clinic_id = clinic_data['siteId']
            clinic.save(validate: false)
          end
        end
      end
    end
  end
end
