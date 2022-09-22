module RenderAppointments
  module RenderPartiallyRenderedSchedulesOperation
    class << self
      def call(client_enrollment_services)
        fully_render_partially_rendered_schedules(client_enrollment_services)
      end

      private

      def fully_render_partially_rendered_schedules(client_enrollment_services_ids)
        schedules = Scheduling.where(client_enrollment_service_id: client_enrollment_services_ids)
        schedules = schedules&.partially_rendered_schedules.and(schedules.completed_scheduling.or(schedules.completed_todays_schedulings))
        schedules&.each do |schedule|
          schedule&.status = 'rendered'
          schedule&.rendered_at = DateTime.current
          schedule&.save
          schedule.audits.order(:created_at).last.update(user_type: 'System')
        end
      end
    end
  end
end
