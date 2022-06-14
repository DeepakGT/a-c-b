module RenderAppointments
  module RenderScheduleOperation
    class << self
      def call(schedule_id)
        render_schedule(schedule_id)
      end

      private

      def render_schedule(schedule_id)
        schedule = Scheduling.find(schedule_id)
        schedule.unrendered_reason = []
        schedule.save(validate: false)
        if schedule.soap_notes.present?
          if schedule.is_soap_notes_assigned.to_bool.true?
            soap_note = schedule.soap_notes.where(synced_with_catalyst: true)&.last
            RenderAppointments::RenderBySoapNoteOperation.call(soap_note.id)
          else
            schedule.soap_notes.each do |soap_note|
              RenderAppointments::RenderBySoapNoteOperation.call(soap_note.id)
              break if schedule.is_rendered.to_bool.true?
            end
          end
        else
          schedule.unrendered_reason = schedule.unrendered_reason | ['soap_note_absent']
          schedule.save(validate: false)
        end
      end
    end
  end
end
