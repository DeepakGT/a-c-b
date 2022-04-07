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
          schedules = Scheduling.where(id: scheduling_ids).where('date < ?', Time.now.to_date)
          if schedules.any?
            schedules.each do |schedule|
              soap_notes = schedule.soap_notes
              if soap_notes.any?
                soap_notes.each do |soap_note|
                  schedule.unrendered_reason = ''
                  if soap_note.bcba_signature==false
                    schedule.unrendered_reason += ' bcba_signature_absent'
                    schedule.save(validate: false)
                  end
                  if soap_note.clinical_director_signature==false 
                    schedule.unrendered_reason += ' clinical_director_signature_absent'
                    schedule.save(validate: false)
                  end
                  if soap_note.rbt_signature==false 
                    schedule.unrendered_reason += ' rbt_signature_absent'
                    schedule.save(validate: false)
                  end
                  if !soap_note.signature_file.attached?
                    schedule.unrendered_reason += ' caregiver_signature_absent'
                    schedule.save(validate: false)
                  end
                  if schedule.unrendered_reason.blank?
                    schedule.is_rendered = true
                    schedule.unrendered_reason = ''
                    schedule.save(validate: false)
                    break
                  end
                end
              else
                schedule.unrendered_reason = 'soap_note_absent'
                schedule.save(validate: false)
              end
            end
          end
        end
        true
      end
    end
  end
end
