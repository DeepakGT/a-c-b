require 'odbc'
require 'sequel'
module Snowflake
  module GetStudentServiceDataService
    class << self
      def call(db)
        client_enrollment_services = get_student_service_data(db)
      end

      private

      def get_student_service_data(db)
        client_enrollment_services = db.fetch("SELECT * FROM PUBLIC.STUDENT_SERVICE;").entries
      end
    end
  end
end
