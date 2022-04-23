module Snowflake
  module SeedClientDataOperation
    class << self
      def call(username, password)
        seed_client_data(username, password)
      end

      private

      def seed_client_data(username, password)
        db = Snowflake::SetDatabaseAndWarehouseService.call(username, password)
        appointments = Snowflake::GetAppointmentAdminDataService.call(db)

        appointments.each do |appointment|
          client_name = appointment['CLIENTNAME']&.split(',')&.each(&:strip!)
          client = Client.find_or_initialize_by(first_name: client_name&.last, last_name: client_name&.first, gender: nil, dob: appointment['CLIENTDOB']&.to_time&.strftime('%Y-%m-%d'), status: appointment['CLIENTSTATUS']&.downcase)
          clinic_name = appointment['CLIENTOFFICENAME']&.downcase
          client.clinic_id = Clinic.where('lower(name) = ? OR lower(aka) = ?', clinic_name, clinic_name)&.first&.id
          client.save(validate: false)
          address = client.addresses.find_or_initialize_by(city: appointment['CLIENTCITY'], zipcode: appointment['CLIENTZIP'], address_type: 'service_address')
          address.is_default = true
          address.save(validate: false)
        end
      end
    end
  end
end
