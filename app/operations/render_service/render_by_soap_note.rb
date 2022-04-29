module RenderService
  module RenderBySoapNote
    class << self
      def call(soap_note_id)
        check_soap_note(soap_note_id)
      end

      private

      def check_soap_note(soap_note_id)
        soap_note = SoapNote.find(soap_note_id)
        schedule = soap_note.scheduling
        schedule.unrendered_reasons = []
        schedule.save(validate: false)
        if soap_note.bcba_signature.to_bool.false?
          schedule.unrendered_reasons = schedule.unrendered_reasons | ['bcba_signature_absent']
          schedule.save(validate: false)
        end
        if soap_note.clinical_director_signature.to_bool.false? 
          schedule.unrendered_reasons = schedule.unrendered_reasons | ['clinical_director_signature_absent']
          schedule.save(validate: false)
        end
        if soap_note.rbt_signature.to_bool.false?  && schedule.staff.role_name=='rbt'
          schedule.unrendered_reasons = schedule.unrendered_reasons | ['rbt_signature_absent']
          schedule.save(validate: false)
        end
        if !soap_note.signature_file.attached? && soap_note.caregiver_signature!=true
          schedule.unrendered_reasons = schedule.unrendered_reasons | ['caregiver_signature_absent']
          schedule.save(validate: false)
        end
        if schedule.unrendered_reasons.blank?
          schedule.is_rendered = true
          schedule.status = 'Rendered' if schedule.client_enrollment_service.client_enrollment.funding_source.name!='ABA Centers of America'
          schedule.rendered_at = DateTime.current
          schedule.save(validate: false)
        end
      end
    end
  end
end
