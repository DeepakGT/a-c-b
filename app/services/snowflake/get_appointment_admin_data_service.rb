if ENV['CLOUD_PLATFORM']!='heroku'
  require 'odbc'
  require 'sequel'
  module Snowflake
    module GetAppointmentAdminDataService
      class << self
        def call(db)
          get_appointment_admin_data(db)
        end

        private

        def get_appointment_admin_data(db)
          db.fetch("SELECT * FROM NPAW.PUBLIC.APPOINTMENTADMIN WHERE servicename IS NOT NULL and staffname IS NOT NULL;").entries
        end
      end
    end
  end
end
