module RenderAppointments
  module RenderScheduleManualOperation
    class << self
      def call(schedule_id, catalyst_notes_ids, current_user)
        manual_render_appointment(schedule_id, catalyst_notes_ids, current_user)
      end

      private

      def manual_render_appointment(schedule_id, catalyst_notes_ids, current_user)
        schedule = Scheduling.find(schedule_id) rescue nil
        schedule&.is_manual_render = true
        schedule&.unrendered_reason = []
        if schedule&.client_enrollment_service&.service&.is_early_code?
          schedule&.rendered_at = nil
          schedule&.status = 'auth_pending' 
        else
          schedule&.rendered_at = DateTime.current
          schedule&.status = 'rendered' 
        end
        schedule&.rendered_by_id = current_user.id
        if catalyst_notes_ids.present? && !catalyst_notes_ids.empty?
          @catalyst_notes = CatalystData.where('id IN (?)', catalyst_notes_ids)
          @catalyst_notes.each do |catalyst_note|
            create_soap_note(schedule, catalyst_note)
            catalyst_note.system_scheduling_id = schedule&.id
            catalyst_note.save(validate: false)
          end
        end
        schedule&.save(validate: false)
      end

      def create_soap_note(schedule, catalyst_data)
        soap_note = SoapNote.find_or_initialize_by(catalyst_data_id: catalyst_data&.id)
        soap_note&.add_date = catalyst_data&.date
        soap_note&.note = catalyst_data&.note
        soap_note&.scheduling_id = schedule&.id
        soap_note&.client_id = schedule&.client_enrollment_service&.client_enrollment&.client_id
        soap_note&.creator_id = schedule&.staff_id
        soap_note&.synced_with_catalyst = true
        soap_note&.bcba_signature = true if catalyst_data&.bcba_signature.present?
        soap_note&.clinical_director_signature = true if catalyst_data&.clinical_director_signature.present?
        soap_note&.caregiver_signature = true if catalyst_data&.caregiver_signature.present?
        if schedule&.staff&.role_name=='rbt' && catalyst_data&.provider_signature.present?
          soap_note&.rbt_signature = true
        elsif schedule&.staff&.role_name=='bcba' && catalyst_data&.provider_signature.present?
          soap_note&.bcba_signature = true
        end
        soap_note&.save(validate: false)
      end
    end
  end
end
