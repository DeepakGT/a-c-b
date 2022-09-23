if ENV['CLOUD_PLATFORM']!='heroku'
  require 'odbc'
  require 'sequel'
  module Snowflake
    module GetStudentServiceDataService
      class << self
        def call(db)
          get_student_service_data(db)
        end

        private

        def get_student_service_data(db)
          db.fetch("SELECT * FROM PUBLIC.STUDENT_SERVICE;").entries
        end
      end
    end
  end
end
