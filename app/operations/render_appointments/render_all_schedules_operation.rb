module RenderAppointments
  module RenderAllSchedulesOperation
    class << self
      def call
        render_schedulings
      end

      private

      def render_schedulings
        schedules = Scheduling.completed_scheduling.where(is_rendered: false).where(catalyst_data_ids: [])
        schedules.each do |schedule|
          RenderAppointments::RenderScheduleOperation.call(schedule.id) if !schedule.unrendered_reason.include?('units_does_not_match')
          if schedule.is_rendered.to_bool.true?
            Loggers::RenderAppointmentsLoggerService.call(schedule.id, "Scheduling #{schedule.id} has been rendered successfully.")
          else
            Loggers::RenderAppointmentsLoggerService.call(schedule.id, "Unrendered reasons for scheduling #{schedule.id} - #{schedule.unrendered_reason}")
          end
        end
      end
    end
  end
end
