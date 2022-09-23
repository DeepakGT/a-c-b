if ENV['CLOUD_PLATFORM']!='heroku'
  require 'odbc'
  require 'sequel'
  module Snowflake
    module SetDatabaseAndWarehouseService
      class << self
        def call(username, password)
          set_database_and_warehouse(username, password)
        end

        private

        def set_database_and_warehouse(username, password)
          db = Sequel.odbc('NPAW', user: username, password: password)
          db.execute("use warehouse COMPUTE_WH;")
          db.execute("use database NPAW;")
          db
        end
      end
    end
  end
end
