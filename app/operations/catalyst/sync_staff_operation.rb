module Catalyst
  module SyncStaffOperation
    STAFF_PASSWORD = 'Staff@1234'.freeze

    class << self
      def call(start_date)
        sync_staff_data(start_date)
      end

      private

      def sync_staff_data(start_date)
        access_token = Catalyst::GetAccessTokenService.call
        staff_data_array = Catalyst::UsersApiService.call(start_date, access_token)

        staff_data_array.each_index do |i|
          staff_data = staff_data_array[i]
          if staff_data['active']==true
            check_staff_details staff_data
            staff = Staff.find_by(first_name: staff_data['firstName'], last_name: staff_data['lastName'], email: staff_data['email'])
            staff = Staff.where('email = ?', staff_data['email']&.downcase).find_by(first_name: staff_data['firstName'], last_name: staff_data['lastName']) if staff.blank?
            if staff.present?
              staff.catalyst_user_id = staff_data['userId']
              staff.save(validate: false)
              Loggers::Catalyst::SyncStaffAndClientsLoggerService.call(i, "Staff #{staff_data['firstName']} #{staff_data['lastName']} catalyst user id is saved.")
            else
              Loggers::Catalyst::SyncStaffAndClientsLoggerService.call(i, "Staff #{staff_data['firstName']} #{staff_data['lastName']} not found.")
            end
          end
        end
      end

      def check_staff_details(staff_data)
        if staff_data['firstName']=='Jacques' && staff_data['lastName']=='Edmond' && staff_data['email']=='jedmond@abacentersfl.com'
          staff_data['firstName']='Jacques '
        elsif staff_data['firstName']=='Maria' && staff_data['lastName']=='Perdomo' && staff_data['email']=='mperdomo@abacentersfl.com'
          staff_data['firstName']='Maria '
        elsif staff_data['firstName']=='Abby' && staff_data['lastName']=='Livigne' && staff_data['email']=='alivigne@abacentersfl.com'
          staff_data['firstName']='Abby '
        elsif staff_data['firstName']=='Rayniyah' && staff_data['lastName']=='Harvin' && staff_data['email']=='rharvin@abacentersfl.com'
          staff_data['firstName']='Rayniyah '
        elsif staff_data['firstName']=='Daria' && staff_data['lastName']=='Yudina' && staff_data['email']=='alivigne@abacentersfl.com'
          staff_data['firstName']='Dariya'
        elsif staff_data['firstName']=='Javislaine' && staff_data['lastName']=='Ceballo Castillo' && staff_data['email']=='jceballocastillo@abacentersfl.com'
          staff_data['lastName']='Ceballo-Castillo'
        elsif staff_data['firstName']=='Brittany' && staff_data['lastName']=='brodeur' && staff_data['email']=='bbrodeur@exactbilling.com'
          staff_data['lastName']='Brodeur'
        elsif staff_data['firstName']=='Jessinia Rodriguez' && staff_data['lastName']=='Jessinia Rodriguez' && staff_data['email']=='jrodriguez@abacentersfl.com'
          staff_data['firstName']='Jessenia'
          staff_data['lastName']='Rodriguez'
        else
          staff_data
        end
      end
    end
  end
end
