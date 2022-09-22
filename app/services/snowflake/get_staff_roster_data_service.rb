if ENV['CLOUD_PLATFORM']!='heroku'
  require 'odbc'
  require 'sequel'
  module Snowflake
    module GetStaffRosterDataService
      class << self
        def call(db)
          get_staff_roster_data(db)
        end

        private

        def get_staff_roster_data(db)
          db.fetch("SELECT * FROM PUBLIC.STAFF_ROSTER;").entries
        end
      end
    end
  end
end
