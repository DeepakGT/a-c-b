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
            response_data_hash = {}
            Loggers::Catalyst::SyncSoapNotesLoggerService.call(data['soapNoteId'], "Started syncing soap note #{data['soapNoteId']} from catalyst.")
            catalyst_data = CatalystData.find_or_initialize_by(catalyst_soap_note_id: data['soapNoteId'])
      
            # if catalyst_data.blank?
              # catalyst_data = CatalystData.new(response: data, catalyst_patient_id: data['patientId'], catalyst_user_id: data['userId'],
              #                                  date: data['date'].to_time.strftime('%Y-%m-%d'), start_time: data['startTime'].to_time.strftime('%H:%M'), 
              #                                  end_time: data['endTime'].to_time.strftime('%H:%M'), catalyst_soap_note_id: data['soapNoteId'], 
              #                                  date_revision_made: data['dateRevisionMade'])
              
            catalyst_data.response = data
            catalyst_data.catalyst_patient_id = data['patientId']
            catalyst_data.catalyst_user_id = data['userId']
            catalyst_data.date = data['date'].to_time.strftime('%Y-%m-%d')
            catalyst_data.start_time = data['startTime'].to_time.strftime('%H:%M')
            catalyst_data.end_time = data['endTime'].to_time.strftime('%H:%M')
            catalyst_data.date_revision_made = data['dateRevisionMade']
            # location = data.select {|res| res["questionText"] == "Location" && res["type"] == "Location"}.first
            # loc = location.present? ? location["answer"] : ""
            # session_location = data.select {|res| res["questionText"] == "Session Location" && res["type"] == "StaticList"}.first
            # session_loc = session_location.present? ? session_location["answer"] : ""
            # catalyst_data.location = loc
            # catalyst_data.session_location = session_loc
            data['responses'].each do |response|
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
              end
            end
            catalyst_data.minutes = (catalyst_data.end_time.to_time - catalyst_data.start_time.to_time)/60
            rem = catalyst_data.minutes%15
            if rem == 0
              catalyst_data.units = catalyst_data.minutes/15
            elsif rem < 8
              catalyst_data.units = (catalyst_data.minutes - rem)/15
            else
              catalyst_data.units = (catalyst_data.minutes + 15 - rem)/15
            end 
            catalyst_data.save(validate: false)
            if catalyst_data.id.nil?
              Loggers::Catalyst::SyncSoapNotesLoggerService.call(catalyst_data.id, "Catalyst soap note with id #{data['soapNoteId']} cannot be saved.")
            else
              Loggers::Catalyst::SyncSoapNotesLoggerService.call(catalyst_data.id, "Catalyst soap note with id #{data['soapNoteId']} is saved.")
              Loggers::Catalyst::SyncSoapNotesLoggerService.call(catalyst_data.id, "#{catalyst_data.attributes}")
            end

            response_data_hash = CompareCatalystDataWithSystemData::CompareSyncedDataOperation.call(catalyst_data)
            # elsif catalyst_data.date_revision_made!=data['dateRevisionMade']
            #   Loggers::Catalyst::SyncSoapNotesLoggerService.call(catalyst_data.id, "#{catalyst_data.attributes}")
            #   data['responses'].each do |response|
            #     case response['questionText']
            #     when 'BCBA Signature'
            #       catalyst_data.bcba_signature = response['answer']
            #     when 'Clinical Director '
            #       catalyst_data.clinical_director_signature = response['answer']
            #     when 'Notes'
            #       catalyst_data.note = response['answer']
            #     when 'Guardian Signature', 'Client/Guardian Signature'
            #       catalyst_data.caregiver_signature = response['answer'] if response['answer'].present?
            #     when 'Provider Signature'
            #       catalyst_data.provider_signature = response['answer']
            #     end
            #   end
            #   catalyst_data.catalyst_patient_id = data['patientId']
            #   catalyst_data.catalyst_user_id = data['userId']
            #   catalyst_data.date = data['date'].to_time.strftime('%Y-%m-%d')
            #   catalyst_data.start_time = data['startTime'].to_time.strftime('%H:%M')
            #   catalyst_data.end_time = data['endTime'].to_time.strftime('%H:%M')
            #   catalyst_data.minutes = (catalyst_data.end_time.to_time - catalyst_data.start_time.to_time)/60
            #   # catalyst_data.units = (catalyst_data.minutes)/15
            #   rem = catalyst_data.minutes%15
            #   if rem == 0
            #     catalyst_data.units = catalyst_data.minutes/15
            #   elsif rem < 8
            #     catalyst_data.units = (catalyst_data.minutes - rem)/15
            #   else
            #     catalyst_data.units = (catalyst_data.minutes + 15 - rem)/15
            #   end 
            #   catalyst_data.response = data
            #   catalyst_data.date_revision_made = data['dateRevisionMade']
            #   catalyst_data.save(validate: false)
            #   if catalyst_data.updated_at.strftime('%Y-%m-%d')==Time.current.strftime('%Y-%m-%d')
            #     Loggers::Catalyst::SyncSoapNotesLoggerService.call(catalyst_data.id, "Catalyst soap note with id #{data['soapNoteId']} is updated.")
            #     Loggers::Catalyst::SyncSoapNotesLoggerService.call(catalyst_data.id, "#{catalyst_data.attributes}")
            #   else
            #     Loggers::Catalyst::SyncSoapNotesLoggerService.call(catalyst_data.id, "Catalyst soap note with id #{data['soapNoteId']} cannot be updated.")
            #   end

            #   # response_data_hash = CompareCatalystDataWithSystemData::CompareSyncedDataOperation.call(catalyst_data)
            #   response_data_hash = CompareCatalystDataWithSystemData::UpdateSyncedDataOperation.call(catalyst_data)
            # else
            #   Loggers::Catalyst::SyncSoapNotesLoggerService.call(catalyst_data.id, "No updation in catalyst data found.")
            # end
            Loggers::Catalyst::SyncSoapNotesLoggerService.call(data['soapNoteId'], "Completed syncing soap note #{data['soapNoteId']} from catalyst.")
            response_data_array.push(response_data_hash) if response_data_hash.present?
          end
        end
        response_data_array
      end
    end
  end
end
