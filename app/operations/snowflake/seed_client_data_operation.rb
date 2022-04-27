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
          appointment = appointment.with_indifferent_access
          client_name = appointment['clientname']&.split(',')&.each(&:strip!)
          client = Client.find_or_initialize_by(first_name: client_name&.last, last_name: client_name&.first, gender: nil, dob: appointment['clientdob']&.to_time&.strftime('%Y-%m-%d'))
          client.status = appointment['clientstatus']&.downcase=='inactive' ? 'inactive' : 'active'
          clinic_name = appointment['clientofficename']&.downcase
          client.clinic_id = Clinic.where('lower(name) = ? OR lower(aka) = ?', clinic_name, clinic_name)&.first&.id
          if client.clinic_id.blank?
            client.clinic_id = Clinic.where("name ILIKE '%#{clinic_name}%' OR aka ILIKE '%#{clinic_name}%'")&.first&.id
            client.clinic_id = Clinic.first.id if client.clinic_id.blank?
          end
          client.save(validate: false)
          address = client.addresses.find_or_initialize_by(city: appointment['clientcity'], zipcode: appointment['clientzip'], address_type: 'service_address')
          address.is_default = true
          address.save(validate: false)
        end
      end
    end
  end
end
