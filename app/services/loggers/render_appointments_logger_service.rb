module Loggers
  module RenderAppointmentsLoggerService
    class << self
      def call(scheduling_data, message)
        log_data_sync(scheduling_data, message)
      end

      private

      def log_data_sync(scheduling_data, message)
        log = Logger.new('log/render_appointments.log')
        log.error StandardError.new("#{scheduling_data}")
        log.info("#{message}\n-----------------------------------------------------------------------------")
      end
    end
  end
end
