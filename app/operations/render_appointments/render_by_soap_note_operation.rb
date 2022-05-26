module RenderAppointments
  module RenderBySoapNoteOperation
    class << self
      def call(soap_note_id)
        check_soap_note(soap_note_id)
      end

      private

      def check_soap_note(soap_note_id)
        soap_note = SoapNote.find(soap_note_id)
        schedule = soap_note.scheduling
        schedule.unrendered_reason = []
        schedule.save(validate: false)
        if soap_note.bcba_signature.to_bool.false?
          schedule.unrendered_reason = schedule.unrendered_reason | ['bcba_signature_absent']
          schedule.save(validate: false)
        end
        # if soap_note.clinical_director_signature.to_bool.false? 
        #   schedule.unrendered_reason = schedule.unrendered_reason | ['clinical_director_signature_absent']
        #   schedule.save(validate: false)
        # end
        if soap_note.rbt_signature.to_bool.false?  && schedule.staff&.role_name=='rbt'
          schedule.unrendered_reason = schedule.unrendered_reason | ['rbt_signature_absent']
          schedule.save(validate: false)
        end
        if !soap_note.signature_file.attached? && soap_note.caregiver_signature!=true
          schedule.unrendered_reason = schedule.unrendered_reason | ['caregiver_signature_absent']
          schedule.save(validate: false)
        end
        if schedule.unrendered_reason.include?('clinical_director_signature_absent')
          schedule.unrendered_reason.delete('clinical_director_signature_absent')
          schedule.save(validate: false)
        end
        if schedule.unrendered_reason.blank?
          schedule.is_rendered = true
          schedule.status = 'Rendered' if schedule.client_enrollment_service&.client_enrollment&.funding_source&.name!='ABA Centers of America'
          schedule.rendered_at = DateTime.current
          schedule.save(validate: false)
        end
      end
    end
  end
end
