if ENV['CLOUD_PLATFORM']!='heroku'
  require 'odbc'
  require 'sequel'
  module Snowflake
    module GetBcbaClientsDataService
      class << self
        def call(db)
          get_bcba_clients_data(db)
        end

        private

        def get_bcba_clients_data(db)
          db.fetch("SELECT * FROM PUBLIC.BCBA_CLIENTS;").entries
        end
      end
    end
  end
end
