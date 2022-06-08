module Loggers
  module Catalyst
    module SyncSoapNotesLoggerService
      class << self
        def call(catalyst_data, message)
          log_data_sync(catalyst_data, message)
        end

        private

        def log_data_sync(catalyst_data, message)
          log = Logger.new("log/catalyst/soap_note/sync_#{Time.current.strftime('%m-%d-%Y')}.log")
          log.error StandardError.new("#{catalyst_data}")
          log.info("#{message}\n-----------------------------------------------------------------------------")
        end
      end
    end
  end
end
