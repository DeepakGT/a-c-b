module Loggers
  module Catalyst
    module SyncStaffAndClientsLoggerService
      class << self
        def call(catalyst_data, message)
          log_data_sync(catalyst_data, message)
        end

        private

        def log_data_sync(catalyst_data, message)
          log = Logger.new('log/catalyst_staff_and_clients_sync.log')
          log.error StandardError.new("#{catalyst_data}")
          log.info("#{message}\n-----------------------------------------------------------------------------")
        end
      end
    end
  end
end
