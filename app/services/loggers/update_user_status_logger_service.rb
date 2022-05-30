module Loggers
  module UpdateUserStatusLoggerService
    class << self
      def call(user_data, message)
        log_data_sync(user_data, message)
      end

      private

      def log_data_sync(user_data, message)
        log = Logger.new('log/update_user_status.log')
        log.error StandardError.new("#{user_data}")
        log.info("#{message}\n-----------------------------------------------------------------------------")
      end
    end
  end
end
