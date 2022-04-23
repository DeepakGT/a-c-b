require 'odbc'
require 'sequel'
module Snowflake
  module GetAppointmentAdminDataService
    class << self
      def call(db)
        appointments = get_appointment_admin_data(db)
      end

      private

      def get_appointment_admin_data(db)
        appointments = db.fetch("SELECT * FROM PUBLIC.APPOINTMENTADMIN;").entries
      end
    end
  end
end
