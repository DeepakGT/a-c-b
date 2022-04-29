module RenderService
  module RenderSchedule
    class << self
      def call(schedule_id)
        render_schedule(schedule_id)
      end

      private

      def render_schedule(schedule_id)
        schedule = Scheduling.find(schedule_id)
        if schedule.soap_notes.present?
          schedule.soap_notes.each do |soap_note|
            RenderService::RenderBySoapNote.call(soap_note.id)
            break if schedule.is_rendered.to_bool.true?
          end
        else
          schedule.unrendered_reasons = schedule.unrendered_reasons | ['soap_note_absent']
          schedule.save(validate: false)
        end
      end
    end
  end
end
