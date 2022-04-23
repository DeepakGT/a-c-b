require 'odbc'
require 'sequel'
module Snowflake
  module GetStaffRosterDataService
    class << self
      def call(db)
        staff_rosters = get_staff_roster_data(db)
      end

      private

      def get_staff_roster_data(db)
        staff_rosters = db.fetch("SELECT * FROM PUBLIC.STAFF_ROSTER;").entries
      end
    end
  end
end
