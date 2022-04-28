module Catalyst
  module RenderServiceOperation
    class << self
      def call
        result = render_service
      end

      private

      def render_service
        scheduling_ids = CatalystData.all&.pluck(:system_scheduling_id)&.uniq
        if scheduling_ids.present?
          schedules = Scheduling.where(id: scheduling_ids).where('date < ?', Time.current.to_date)
          if schedules.any?
            schedules.each do |schedule|
              if schedule.unrendered_reason.blank?
                RenderService::RenderSchedule.call(schedule.id)
              end
            end
          end
        end
        true
      end
    end
  end
end
