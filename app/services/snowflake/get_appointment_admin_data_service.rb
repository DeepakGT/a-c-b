if ENV['CLOUD_PLATFORM']!='heroku'
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
          appointments = db.fetch("SELECT * FROM NPAW.PUBLIC.APPOINTMENTADMIN WHERE APPTDATE >= '2021-10-01T00:00:00';").entries
        end
      end
    end
  end
end
