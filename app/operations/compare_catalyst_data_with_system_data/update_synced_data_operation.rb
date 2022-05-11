module CompareCatalystDataWithSystemData
  module UpdateSyncedDataOperation
    class << self
      def call(catalyst_data)
        response_data_hash = update_synced_data(catalyst_data)
      end

      private

      def update_synced_data(catalyst_data)
        if catalyst_data.system_scheduling_id.present?
          schedule = Scheduling.find(catalyst_data.system_scheduling_id)
          min_start_time = (catalyst_data.start_time.to_time-15.minutes)
          max_start_time = (catalyst_data.start_time.to_time+15.minutes)
          min_end_time = (catalyst_data.end_time.to_time-15.minutes)
          max_end_time = (catalyst_data.end_time.to_time+15.minutes)
          min_units = (catalyst_data.units-1)
          max_units = (catalyst_data.units+1)
          response_data_hash = Hash.new

          if (min_start_time..max_start_time).include?(schedule.start_time.to_time) && (min_end_time..max_end_time).include?(schedule.end_time.to_time) && (min_units..max_units).include?(schedule.units) 
            schedule.update(start_time: catalyst_data.start_time, end_time: catalyst_data.end_time)
            schedule.units = catalyst_data.units if schedule.units.present?
            schedule.minutes = catalyst_data.minutes if schedule.minutes.present?
            schedule.catalyst_data_ids.push(catalyst_data.id)
            schedule.save(validate: false)
            soap_note = schedule.soap_notes.find_or_initialize_by(catalyst_data_id: catalyst_data.id)
            soap_note.add_date = catalyst_data.date
            soap_note.note = catalyst_data.note
            soap_note.creator_id = schedule.staff_id
            soap_note.synced_with_catalyst = true
            soap_note.bcba_signature = true if catalyst_data.bcba_signature.present?
            soap_note.clinical_director_signature = true if catalyst_data.clinical_director_signature.present?
            soap_note.caregiver_signature = true if catalyst_data.caregiver_signature.present?
            if schedule.staff.role_name=='rbt' && catalyst_data.provider_signature.present?
              soap_note.rbt_signature = true
            elsif schedule.staff.role_name=='bcba' && catalyst_data.provider_signature.present?
              soap_note.bcba_signature = true
            end
            soap_note.save(validate: false)
            response_data_hash = {}
          else
            schedule.unrendered_reason = schedule.unrendered_reason | ['units_does_not_match']
            schedule.catalyst_data_ids = schedule.catalyst_data_ids | ["#{catalyst_data.id}"]
            schedule.save(validate: false)
            response_data_hash[:system_data] = schedule.attributes
            response_data_hash[:catalyst_data] = catalyst_data.attributes
          end
          response_data_hash
        end
      end
    end
  end
end
