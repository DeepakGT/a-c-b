module RenderAppointments
  module MultipleSoapNotesOperation
    class << self
      def call
        split_appointments
      end

      private

      def split_appointments
        schedules = Scheduling.where.not(catalyst_data_ids: [])
        schedules.each do |schedule|
          schedule.catalyst_data_ids = schedule.catalyst_data_ids.uniq
          schedule.save(validate: false)
        end

        schedules = schedules.unrendered_schedulings.completed_scheduling.where(is_soap_notes_assigned: false)
        schedules = schedules.map{|schedule| schedule if schedule.catalyst_data_ids.count>=2}.compact!
        schedules.each do |schedule|
          catalyst_datas = CatalystData.where(id: schedule.catalyst_data_ids)
          session_locations = catalyst_datas.pluck(:session_location).uniq
          if session_locations.present? && session_locations.count > 1 
            schedule.unrendered_reason = ['split_appointments']
            schedule.save(validate: false)
          else
            schedule.unrendered_reason = ['multiple_soap_notes_found']
            schedule.save(validate: false)
          # elsif session_locations.present? && session_locations.count == catalyst_data_ids.count
          #   schedule.unrendered_reason = ['multiple_soap_notes_of_different_locations_found']
          #   schedule.save(validate: false)
          end
        end
      end
    end
  end
end
