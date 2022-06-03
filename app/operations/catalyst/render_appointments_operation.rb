module Catalyst
  module RenderAppointmentsOperation
    class << self
      def call
        render_service
      end

      private

      def render_service
        scheduling_ids = Scheduling.where.not(catalyst_data_ids: []).ids
        if scheduling_ids.present?
          Loggers::Catalyst::SyncSoapNotesLoggerService.call(scheduling_ids.count, "Rendering #{scheduling_ids.count} appointments started.")
          schedules = Scheduling.where(id: scheduling_ids).completed_scheduling.unrendered_schedulings
          if schedules.any?
            schedules.each do |schedule|
              if !schedule.unrendered_reason.include?('units_does_not_match')
                RenderAppointments::RenderScheduleOperation.call(schedule.id)
                if schedule.is_rendered.to_bool.true?
                  Loggers::Catalyst::SyncSoapNotesLoggerService.call(schedule.id, "Schedule has been rendered successfully.")
                else
                  Loggers::Catalyst::SyncSoapNotesLoggerService.call(schedule.id, "Unrendered reason - #{schedule.unrendered_reason}")
                end
              else
                Loggers::Catalyst::SyncSoapNotesLoggerService.call(schedule.id, "Unrendered reason - #{schedule.unrendered_reason}")
              end
            end
          end
        else
          Loggers::Catalyst::SyncSoapNotesLoggerService.call(nil, "Zero schedules found to render.")
        end
      end
    end
  end
end
