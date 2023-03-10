module RenderAppointments
  module RenderAllSchedulesOperation
    class << self
      def call
        render_schedulings
      end

      private

      def render_schedulings
        schedules = Scheduling.completed_scheduling.unrendered_schedulings.where(catalyst_data_ids: []).by_status
        schedules.each do |schedule|
          RenderAppointments::RenderScheduleOperation.call(schedule.id) if !schedule.unrendered_reason.include?('units_does_not_match')
          if schedule.rendered_at.present?
            Loggers::RenderAppointmentsLoggerService.call(schedule.id, "Scheduling #{schedule.id} has been rendered successfully.")
          else
            Loggers::RenderAppointmentsLoggerService.call(schedule.id, "Unrendered reasons for scheduling #{schedule.id} - #{schedule.unrendered_reason}")
          end
        end
      end
    end
  end
end
