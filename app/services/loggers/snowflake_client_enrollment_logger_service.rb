module Loggers
  module SnowflakeClientEnrollmentLoggerService
    class << self
      def call(snowflake_data, message)
        log_data_sync(snowflake_data, message)
      end

      private

      def log_data_sync(snowflake_data, message)
        log = Logger.new('log/snowflake_client_enrollment.log')
        log.error StandardError.new("#{snowflake_data}")
        log.info("#{message}\n-----------------------------------------------------------------------------")
      end
    end
  end
end
