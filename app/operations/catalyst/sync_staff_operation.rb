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
          end
          staff = Staff.find_by(first_name: staff_data['firstName'], last_name: staff_data['lastName'], email: staff_data['email'])
          if staff.blank?
            staff = Staff.where('email = ?', staff_data['email']&.downcase).find_by(first_name: staff_data['firstName'], last_name: staff_data['lastName'])
          end
          if staff.present?
            staff.catalyst_user_id = staff_data['userId']
            staff.save(validate: false)
            Loggers::Catalyst::SyncStaffAndClientsLoggerService.call(i, "Staff #{staff_data['firstName']} #{staff_data['lastName']} catalyst user id is saved.")
          # else
          #   # create staff
          #   staff = Staff.new(first_name: staff_data['firstName'], last_name: staff_data['lastName'], email: staff_data['email'], catalyst_user_id: staff_data['userId'], password: STAFF_PASSWORD, password_confirmation: STAFF_PASSWORD)
          #   # staff.status = 'inactive' if staff_data['active']
          #   staff.status = staff_data['active'].true? ? 'active' : 'inactive'
          #   staff.gender = nil
          #   # staff.role 
          #   # staff.job_type
          #   staff.save(validate: false)

          #   # staff_clinics
          #   clinics = Clinic.where(catalyst_clinic_id: staff_data['siteAssignments'])
          #   clinics.each do |clinic|
          #     staff_clinic = staff.staff_clinics.new(clinic_id: clinic.id)
          #     staff_clinic.save(validate: false)
          #   end
          #   staff.staff_clinics&.first&.update(is_home_clinic: true)

          #   # staff_phone
          #   staff_phone = staff.phone_numbers.new(number: staff_data['phone1'])
          #   staff_phone.save(validate: false)

          #   # staff_address
          #   country_name = Country.find_by(code: staff_data['countryCode']) if staff_data['countryCode'].present? && staff_data['countryCode']!='NOT DEFINED'
          #   address = Address.new(addressable_type: 'User', addressable_id: staff.id)
          #   address.line1 = staff_data['street1'] if staff_data['street1'].present? && staff_data['street1']!='NOT DEFINED'
          #   address.city = staff_data['city'] if staff_data['city'].present? && staff_data['city']!='NOT DEFINED'
          #   address.state = staff_data['stateCode'] if staff_data['stateCode'].present? && staff_data['stateCode']!='NOT DEFINED'
          #   address.zipcode = staff_data['postalCode'] if staff_data['postalCode'].present? && staff_data['postalCode']!='NOT DEFINED'
          #   address.country = country_name if country_name.present?
          #   address.save(validate: false) if address.line1.present? || address.city.present? || address.state.present? || address.country.present? || address.zipcode.present?
          else
            Loggers::Catalyst::SyncStaffAndClientsLoggerService.call(i, "Staff #{staff_data['firstName']} #{staff_data['lastName']} not found.")
          end
        end
      end
    end
  end
end
