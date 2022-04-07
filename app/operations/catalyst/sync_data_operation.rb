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
              catalyst_data = CatalystData.create(response: data, client_first_name: data['userFirstName'], client_last_name: data['userLastName'],
                staff_first_name: data['patientFirstName'], staff_last_name: data['patientLastName'], date: data['date'].to_time.strftime('%Y-%m-%d'), 
                start_time: data['startTime'].to_time.strftime('%H:%M'), end_time: data['endTime'].to_time.strftime('%H:%M'),
                catalyst_soap_note_id: data['soapNoteId'])
            else
              catalyst_data.update(response: data, client_first_name: data['userFirstName'], client_last_name: data['userLastName'],
                staff_first_name: data['patientFirstName'], staff_last_name: data['patientLastName'], date: data['date'].to_time.strftime('%Y-%m-%d'), 
                start_time: data['startTime'].to_time.strftime('%H:%M'), end_time: data['endTime'].to_time.strftime('%H:%M'))
            end
      
            data['responses'].each do |response|
              if response['questionText']=='BCBA Signature'
                catalyst_data.bcba_signature = response['answer']
              elsif response['questionText']=='Clinical Director '
                catalyst_data.clinical_director_signature = response['answer']
              elsif response['questionText']=='Notes'
                catalyst_data.note = response['answer']
              end
            end
            catalyst_data.save
            
            staff = Staff.find_by(first_name: catalyst_data.staff_first_name, last_name: catalyst_data.staff_last_name)
            client = Client.find_by(first_name: catalyst_data.client_first_name, last_name: catalyst_data.client_last_name)
            schedules = Scheduling.joins(client_enrollment_service: :client_enrollment).where('client_enrollments.client_id = ?', client&.id)
                                  .where(date: catalyst_data.date, staff_id: staff&.id)

            if schedules.any?
              schedules.each do |schedule|
                min_start_time = (catalyst_data.start_time.to_time-15.minutes).strftime('%H:%M')
                max_start_time = (catalyst_data.start_time.to_time+15.minutes).strftime('%H:%M')
                min_end_time = (catalyst_data.end_time.to_time-15.minutes).strftime('%H:%M')
                max_end_time = (catalyst_data.end_time.to_time+15.minutes).strftime('%H:%M')
                if (min_start_time..max_start_time).include?(schedule.start_time) && (min_end_time..max_end_time).include?(schedule.end_time)
                  schedule.update(start_time: catalyst_data.start_time, end_time: catalyst_data.end_time)
                  soap_note = schedule.soap_notes.new(add_date: catalyst_data.date, note: catalyst_data.note)
                  soap_note.bcba_signature = true if catalyst_data.bcba_signature.present?
                  soap_note.clinical_director_signature = true if catalyst_data.clinical_director_signature.present?
                  soap_note.save(validate: false)

                  response_data_hash = {}
                  catalyst_data.system_scheduling_id = schedule.id
                  catalyst_data.save
                  break
                else
                  response_data_hash[:system_data] = schedule
                  response_data_hash[:catalyst_data] = catalyst_data
                end
              end
            else
              response_data_hash[:catalyst_data] = catalyst_data
            end
            response_data_array.push(response_data_hash) if response_data_hash.any?
          end
        end
        response_data_array
      end
    end
  end
end
