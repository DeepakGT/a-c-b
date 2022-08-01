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
        # if soap_note.bcba_signature.to_bool.false?
        #   schedule.unrendered_reason = schedule.unrendered_reason | ['bcba_signature_absent']
        #   schedule.save(validate: false)
        # end
        # if soap_note.clinical_director_signature.to_bool.false? 
        #   schedule.unrendered_reason = schedule.unrendered_reason | ['clinical_director_signature_absent']
        #   schedule.save(validate: false)
        # end
        # if soap_note.rbt_signature.to_bool.false? && schedule.staff&.role_name=='rbt'
        #   schedule.unrendered_reason = schedule.unrendered_reason | ['rbt_signature_absent']
        #   schedule.save(validate: false)
        # end
        # service_ids = Service.where(display_code: '99999').ids
        # if !soap_note.signature_file.attached? && soap_note.caregiver_signature!=true && service_ids.include?(soap_note&.scheduling&.client_enrollment_service&.service_id)
        #   schedule.unrendered_reason = schedule.unrendered_reason | ['caregiver_signature_absent']
        #   schedule.save(validate: false)
        # end
        # if schedule.unrendered_reason.include?('clinical_director_signature_absent')
        #   schedule.unrendered_reason.delete('clinical_director_signature_absent')
        #   schedule.save(validate: false)
        # end
        if schedule.unrendered_reason.blank?
          if schedule.client_enrollment_service&.service&.is_early_code?
            schedule.status = 'Auth_Pending'
            schedule.rendered_at = nil
          else
            schedule.status = 'Rendered' 
            schedule.rendered_at = DateTime.current
          end
          schedule.save(validate: false)
        end
      end
    end
  end
end
