module Catalyst
  module RenderAppointmentsOperation
    class << self
      def call
        render_service
      end

      private

      def render_service
        scheduling_ids = CatalystData.all&.pluck(:system_scheduling_id)&.uniq
        if scheduling_ids.present?
          schedules = Scheduling.where(id: scheduling_ids).completed_scheduling.unrendered_schedulings
          if schedules.any?
            schedules.each do |schedule|
              if !schedule.unrendered_reason.include?('units_does_not_match')
                RenderAppointments::RenderScheduleOperation.call(schedule.id)
              end
            end
          end
        end
      end
    end
  end
end
