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
            changes = 0
            if catalyst_data.blank?
              changes = 1
              catalyst_data = CatalystData.create(response: data, client_first_name: data['userFirstName'], client_last_name: data['userLastName'],
                staff_first_name: data['patientFirstName'], staff_last_name: data['patientLastName'], date: data['date'].to_time.strftime('%Y-%m-%d'), 
                start_time: data['startTime'].to_time.strftime('%H:%M'), end_time: data['endTime'].to_time.strftime('%H:%M'),
                catalyst_soap_note_id: data['soapNoteId'])
            else
              if catalyst_data.client_first_name!=data['patientFirstName']
                changes = changes+1
                catalyst_data.update(client_first_name: data['patientFirstName'])
              end
              if catalyst_data.client_last_name!=data['patientLastName']
                changes = changes+1
                catalyst_data.update(client_last_name: data['patientLastName'])
              end
              if catalyst_data.staff_first_name!=data['userFirstName']
                changes = changes+1
                catalyst_data.update(staff_first_name: data['userFirstName'])
              end
              if catalyst_data.staff_last_name!=data['userLastName']
                changes = changes+1
                catalyst_data.update(staff_last_name: data['userLastName'])
              end
              if catalyst_data.date.to_date!=data['date'].to_date
                changes = changes+1
                catalyst_data.update(date: data['date'].to_time.strftime('%Y-%m-%d'))
              end
              if catalyst_data.start_time!=data['startTime'].to_time.strftime('%H:%M')
                changes = changes+1
                catalyst_data.update(start_time: data['startTime'].to_time.strftime('%H:%M'))
              end
              if catalyst_data.end_time!=data['endTime'].to_time.strftime('%H:%M')
                changes = changes+1
                catalyst_data.update(end_time: data['endTime'].to_time.strftime('%H:%M'))
              end
              data['responses'].each do |response|
                if response['questionText']=='BCBA Signature' && catalyst_data.bcba_signature!=response['answer']
                  changes = changes+1
                  catalyst_data.bcba_signature = response['answer']
                elsif response['questionText']=='Clinical Director ' && catalyst_data.clinical_director_signature!=response['answer']
                  changes = changes+1
                  catalyst_data.clinical_director_signature = response['answer']
                elsif response['questionText']=='Notes' && catalyst_data.note!=response['answer']
                  changes = changes+1
                  catalyst_data.note = response['answer']
                elsif response['questionText']=='Guardian Signature' && catalyst_data.caregiver_signature!=response['answer']
                  changes = changes+1
                  catalyst_data.caregiver_signature = response['answer']
                elsif response['questionText']=='Provider Signature' && catalyst_data.provider_signature!=response['answer']
                  changes = changes+1
                  catalyst_data.provider_signature = response['answer']
                end
              end
            end
      
            if changes>0
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
                  catalyst_data.caregiver_signature = response['answer']
                end
              end
              catalyst_data.minutes = (catalyst_data.end_time.to_time - catalyst_data.start_time.to_time)/60
              catalyst_data.units = (catalyst_data.minutes)/15
              catalyst_data.response = data
              catalyst_data.save
              
              response_data_hash = CompareCatalystDataWithSystemData::CompareSyncedData.call(catalyst_data)
            end
            response_data_array.push(response_data_hash) if response_data_hash.any?
          end
        end
        response_data_array
      end
    end
  end
end
