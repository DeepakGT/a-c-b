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
        response_data_array = Array.new
        if data_array.any?
          data_array.each do |data|
            response_data_hash = Hash.new
            catalyst_data = CatalystData.find_by(catalyst_soap_note_id: data['soapNoteId'])
      
            if catalyst_data.blank?
              catalyst_data = CatalystData.create(response: data, catalyst_patient_id: data['patientId'], catalyst_user_id: data['userId'],
                date: data['date'].to_time.strftime('%Y-%m-%d'), start_time: data['startTime'].to_time.strftime('%H:%M'), 
                end_time: data['endTime'].to_time.strftime('%H:%M'), catalyst_soap_note_id: data['soapNoteId'], 
                date_revision_made: data['dateRevisionMade'])
              
              data['responses'].each do |response|
                if response['questionText']=='BCBA Signature'
                  catalyst_data.bcba_signature = response['answer']
                elsif response['questionText']=='Clinical Director '
                  catalyst_data.clinical_director_signature = response['answer']
                elsif response['questionText']=='Notes'
                  catalyst_data.note = response['answer']
                elsif response['questionText']=='Guardian Signature'
                  catalyst_data.caregiver_signature = response['answer']
                elsif response['questionText']=='Provider Signature'
                  catalyst_data.provider_signature = response['answer']
                end
              end
              catalyst_data.minutes = (catalyst_data.end_time.to_time - catalyst_data.start_time.to_time)/60
              # catalyst_data.units = (catalyst_data.minutes)/15
              rem = catalyst_data.minutes%15
              if rem == 0
                catalyst_data.units = catalyst_data.minutes/15
              else
                if rem < 8
                  catalyst_data.units = (catalyst_data.minutes - rem)/15
                else
                  catalyst_data.units = (catalyst_data.minutes + 15 - rem)/15
                end
              end 
              catalyst_data.save(validate: false)

              response_data_hash = CompareCatalystDataWithSystemData::CompareSyncedDataOperation.call(catalyst_data)
            else
              if catalyst_data.date_revision_made!=data['dateRevisionMade']
                data['responses'].each do |response|
                  if response['questionText']=='BCBA Signature'
                    catalyst_data.bcba_signature = response['answer']
                  elsif response['questionText']=='Clinical Director '
                    catalyst_data.clinical_director_signature = response['answer']
                  elsif response['questionText']=='Notes'
                    catalyst_data.note = response['answer']
                  elsif response['questionText']=='Guardian Signature'
                    catalyst_data.caregiver_signature = response['answer']
                  elsif response['questionText']=='Provider Signature'
                    catalyst_data.provider_signature = response['answer']
                  end
                end
                catalyst_data.catalyst_patient_id = data['patientId']
                catalyst_data.catalyst_user_id = data['userId']
                catalyst_data.date = data['date'].to_time.strftime('%Y-%m-%d')
                catalyst_data.start_time = data['startTime'].to_time.strftime('%H:%M')
                catalyst_data.end_time = data['endTime'].to_time.strftime('%H:%M')
                catalyst_data.minutes = (catalyst_data.end_time.to_time - catalyst_data.start_time.to_time)/60
                # catalyst_data.units = (catalyst_data.minutes)/15
                rem = catalyst_data.minutes%15
                if rem == 0
                  catalyst_data.units = catalyst_data.minutes/15
                else
                  if rem < 8
                    catalyst_data.units = (catalyst_data.minutes - rem)/15
                  else
                    catalyst_data.units = (catalyst_data.minutes + 15 - rem)/15
                  end
                end 
                catalyst_data.response = data
                catalyst_data.date_revision_made = data['dateRevisionMade']
                catalyst_data.save(validate: false)
                
                # response_data_hash = CompareCatalystDataWithSystemData::CompareSyncedDataOperation.call(catalyst_data)
                response_data_hash = CompareCatalystDataWithSystemData::UpdateSyncedDataOperation.call(catalyst_data)
              end
            end
            response_data_array.push(response_data_hash) if response_data_hash.present?
          end
        end
        response_data_array
      end
    end
  end
end
