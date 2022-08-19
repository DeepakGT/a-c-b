module RenderAppointments
  module RenderScheduleOperation
    class << self
      def call(schedule_id)
        render_schedule(schedule_id)
      end

      private

      def render_schedule(schedule_id)
        schedule = Scheduling.find(schedule_id)  rescue nil
        schedule&.unrendered_reason = []
        schedule&.save(validate: false)
        if schedule&.soap_notes&.present?
          soap_note = schedule.soap_notes.last
          RenderAppointments::RenderBySoapNoteOperation.call(soap_note.id)
        else
          schedule&.unrendered_reason = schedule&.unrendered_reason | ['soap_note_absent']
          schedule&.save(validate: false)
        end
      end
    end
  end
end
