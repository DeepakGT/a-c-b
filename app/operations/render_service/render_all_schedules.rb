module RenderService
  module RenderAllSchedules
    class << self
      def call
        render_schedulings
      end

      private

      def render_schedulings
        schedules = Scheduling.completed_scheduling.where(is_rendered: false).where(catalyst_data_ids: [])
        schedules.each do |schedule|
          RenderService::RenderSchedule.call(schedule.id)
        end
      end
    end
  end
end
