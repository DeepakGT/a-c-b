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
          schedules = Scheduling.where(id: scheduling_ids).completed_scheduling.unrendered_schedulings.by_status
          if schedules.any?
            schedules.each do |schedule|
              schedule.catalyst_data_ids.uniq!
              schedule.save(validate: false)
              if schedule.unrendered_reason.include?('units_does_not_match') && schedule.catalyst_data_ids.blank?
                schedule.unrendered_reason = []
                schedule.save(validate: false)
              end
              if !schedule.unrendered_reason.include?('units_does_not_match') && !schedule.unrendered_reason.include?('multiple_soap_notes_found') && !schedule.unrendered_reason.include?('multiple_soap_notes_of_different_locations_found')
                RenderAppointments::RenderScheduleOperation.call(schedule.id)
                if schedule.rendered_at.present?
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
