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
              if schedule.unrendered_reason.blank?
                soap_notes = schedule.soap_notes
                if soap_notes.any?
                  soap_notes.each do |soap_note|
                    if soap_note.bcba_signature.to_bool.false?
                      schedule.unrendered_reason.push('bcba_signature_absent')
                      schedule.unrendered_reason = schedule.unrendered_reason.uniq
                      schedule.save(validate: false)
                    end
                    if soap_note.clinical_director_signature.to_bool.false? 
                      schedule.unrendered_reason.push('clinical_director_signature_absent')
                      schedule.unrendered_reason = schedule.unrendered_reason.uniq
                      schedule.save(validate: false)
                    end
                    if soap_note.rbt_signature.to_bool.false? && schedule.staff.role_name=='rbt'
                      schedule.unrendered_reason.push('rbt_signature_absent')
                      schedule.unrendered_reason = schedule.unrendered_reason.uniq
                      schedule.save(validate: false)
                    end
                    if !soap_note.signature_file.attached? && soap_note.caregiver_signature!=true
                      schedule.unrendered_reason.push('caregiver_signature_absent')
                      schedule.unrendered_reason = schedule.unrendered_reason.uniq
                      schedule.save(validate: false)
                    end
                    if schedule.unrendered_reason.blank?
                      schedule.is_rendered = true
                      schedule.save(validate: false)
                      break
                    end
                  end
                else
                  schedule.unrendered_reason.push('soap_note_absent')
                  schedule.unrendered_reason = schedule.unrendered_reason.uniq
                  schedule.save(validate: false)
                end
              end
            end
          end
        end
        true
      end
    end
  end
end
