module Catalyst
  module SyncDataOperation
    class << self
      def call(start_date, end_date)
        sync_data(start_date, end_date)
      end

      private

      def sync_data(start_date, end_date)
        access_token = Catalyst::GetAccessTokenService.call
        data_array = Catalyst::SoapNotesApiService.call(start_date, end_date, access_token)
        response_data_array = []

        Loggers::Catalyst::SyncSoapNotesLoggerService.call(data_array.count, "Received #{data_array.count} soap notes from catalyst.")
        if data_array.any?
          data_array.each do |data|
            if data['isDeleted'].to_bool.false?
              response_data_hash = {}
              Loggers::Catalyst::SyncSoapNotesLoggerService.call(data['soapNoteId'], "Started syncing soap note #{data['soapNoteId']} from catalyst.")
              catalyst_data = CatalystData.find_or_initialize_by(catalyst_soap_note_id: data['soapNoteId'])
                
              catalyst_data.response = data
              catalyst_data.catalyst_patient_id = data['patientId']
              catalyst_data.catalyst_user_id = data['userId']
              catalyst_data.date = data['date'].to_time.strftime('%Y-%m-%d')
              catalyst_data.start_time = data['startTime'].to_time.strftime('%H:%M')
              catalyst_data.end_time = data['endTime'].to_time.strftime('%H:%M')
              catalyst_data.date_revision_made = data['dateRevisionMade']
              data['responses'].each do |response|
                update_signature_and_location(response, catalyst_data)
              end
              catalyst_data.minutes = (catalyst_data.end_time.to_time - catalyst_data.start_time.to_time)/60
              rem = catalyst_data.minutes%15
              update_units(rem, catalyst_data)
              catalyst_data.save(validate: false)
              log_info(catalyst_data)

              staff = staff_details(catalyst_data)
              soap_note = SoapNote.find_or_initialize_by(catalyst_data_id: catalyst_data.id)
              soap_note.add_date = catalyst_data.date
              soap_note.note = catalyst_data.note
              soap_note.creator_id = staff&.id
              soap_note.synced_with_catalyst = true
              soap_note.bcba_signature = true if catalyst_data.bcba_signature.present?
              soap_note.clinical_director_signature = true if catalyst_data.clinical_director_signature.present?
              soap_note.caregiver_signature = true if catalyst_data.caregiver_signature.present?
              if catalyst_data.provider_signature.present? && staff&.role_name=='bcba'
                soap_note.bcba_signature = true
              elsif catalyst_data.provider_signature.present? && (staff&.role_name=='rbt' || staff&.role_name=='Lead RBT')
                soap_note.rbt_signature = true
              end
              soap_note.save(validate: false)

              response_data_hash = CompareCatalystDataWithSystemData::CompareSyncedDataOperation.call(catalyst_data) if catalyst_data.system_scheduling_id.blank?
              
              Loggers::Catalyst::SyncSoapNotesLoggerService.call(data['soapNoteId'], "Completed syncing soap note #{data['soapNoteId']} from catalyst.")
              response_data_array.push(response_data_hash) if response_data_hash.present?
            end
          end
        end
        response_data_array
      end

      def update_signature_and_location(response, catalyst_data)
        case response['questionText']
        when 'BCBA Signature'
          catalyst_data.bcba_signature = response['answer']
        when 'Clinical Director '
          catalyst_data.clinical_director_signature = response['answer']
        when 'Notes'
          catalyst_data.note = response['answer']
        when 'Guardian Signature', 'Client/Guardian Signature'
          catalyst_data.caregiver_signature = response['answer'] if response['answer'].present?
        when 'Provider Signature'
          catalyst_data.provider_signature = response['answer']
        when 'Location'
          catalyst_data.location = response['answer']
        when 'Session Location'
          catalyst_data.session_location = response['answer']
        else
          catalyst_data
        end
      end

      def update_units(rem, catalyst_data)
        if rem == 0
          catalyst_data.units = catalyst_data.minutes/15
        elsif rem < 8
          catalyst_data.units = (catalyst_data.minutes - rem)/15
        else
          catalyst_data.units = (catalyst_data.minutes + 15 - rem)/15
        end 
      end

      def log_info(catalyst_data)
        if catalyst_data.id.nil?
          Loggers::Catalyst::SyncSoapNotesLoggerService.call(catalyst_data.id, "Catalyst soap note with id #{data['soapNoteId']} cannot be saved.")
        else
          Loggers::Catalyst::SyncSoapNotesLoggerService.call(catalyst_data.id, "Catalyst soap note with id #{data['soapNoteId']} is saved.")
          Loggers::Catalyst::SyncSoapNotesLoggerService.call(catalyst_data.id, "#{catalyst_data.attributes}")
        end
      end

      def staff_details(catalyst_data)
        staff = Staff.where(catalyst_user_id: catalyst_data.catalyst_user_id)
        if staff.count==1
          staff = staff.first
        elsif staff.count>1
          staff = staff.find_by(status: 'active')
        else
          staff = Staff.find_by(catalyst_user_id: catalyst_data.catalyst_user_id)
        end
        staff
      end
    end
  end
end
