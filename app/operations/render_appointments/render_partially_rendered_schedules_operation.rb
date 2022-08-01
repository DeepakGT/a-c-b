module RenderAppointments
  module RenderPartiallyRenderedSchedulesOperation
    class << self
      def call(client_enrollment_services)
        fully_render_partially_rendered_schedules(client_enrollment_services)
      end

      private

      def fully_render_partially_rendered_schedules(client_enrollment_services_ids)
        schedules = Scheduling.where(client_enrollment_service_id: client_enrollment_services_ids)
        schedules = schedules.completed_scheduling.partially_rendered_schedules
        schedules.each do |schedule|
          schedule.status = 'Rendered'
          schedule.rendered_at = DateTime.current
          schedule.save(validate: false)
        end
      end
    end
  end
end
