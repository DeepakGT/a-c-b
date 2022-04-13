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
              if catalyst_data.client_first_name!=data['userFirstName']
                changes = changes+1
                catalyst_data.update(client_first_name: data['userFirstName'])
              end
              if catalyst_data.client_last_name!=data['userLastName']
                changes = changes+1
                catalyst_data.update(client_last_name: data['userLastName'])
              end
              if catalyst_data.staff_first_name!=data['patientFirstName']
                changes = changes+1
                catalyst_data.update(staff_first_name: data['patientFirstName'])
              end
              if catalyst_data.staff_last_name!=data['patientLastName']
                changes = changes+1
                catalyst_data.update(staff_last_name: data['patientLastName'])
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
              # catalyst_data.update(response: data,client_first_name: data['userFirstName'], client_last_name: data['userLastName'],
              #   staff_first_name: data['patientFirstName'], staff_last_name: data['patientLastName'], date: data['date'].to_time.strftime('%Y-%m-%d'), 
              #   start_time: data['startTime'].to_time.strftime('%H:%M'), end_time: data['endTime'].to_time.strftime('%H:%M'))
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
              
              staff = Staff.find_by(first_name: catalyst_data.staff_first_name, last_name: catalyst_data.staff_last_name)
              client = Client.find_by(first_name: catalyst_data.client_first_name, last_name: catalyst_data.client_last_name)
              schedules = Scheduling.by_client_ids(client&.id).by_staff_ids(staff&.id).on_date(catalyst_data.date)

              if schedules.count==1
                schedule = schedules.first
                min_start_time = (catalyst_data.start_time.to_time-15.minutes)
                max_start_time = (catalyst_data.start_time.to_time+15.minutes)
                min_end_time = (catalyst_data.end_time.to_time-15.minutes)
                max_end_time = (catalyst_data.end_time.to_time+15.minutes)
                if (min_start_time..max_start_time).include?(schedule.start_time.to_time) && (min_end_time..max_end_time).include?(schedule.end_time.to_time)
                  schedule.update(start_time: catalyst_data.start_time, end_time: catalyst_data.end_time)
                  schedule.units = catalyst_data.units if schedule.units.present?
                  schedule.minutes = catalyst_data.minutes if schedule.minutes.present?
                  schedule.catalyst_data_ids.push(catalyst_data.id)
                  schedule.save(validate: false)
                  soap_note = schedule.soap_notes.new(add_date: catalyst_data.date, note: catalyst_data.note, creator_id: schedule.staff_id)
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
                  schedule.unrendered_reason.push('units_does_not_match')
                  schedule.unrendered_reason = schedule.unrendered_reason.uniq
                  schedule.catalyst_data_ids.push(catalyst_data.id)
                  schedule.catalyst_data_ids = schedule.catalyst_data_ids.uniq
                  schedule.save(validate: false)
                  response_data_hash[:system_data] = schedule
                  response_data_hash[:catalyst_data] = catalyst_data
                end
                catalyst_data.system_scheduling_id = schedule.id
                catalyst_data.is_appointment_found = true
                catalyst_data.save
              elsif schedules.any?
                schedules.each do |schedule|
                  min_start_time = (catalyst_data.start_time.to_time-15.minutes)
                  max_start_time = (catalyst_data.start_time.to_time+15.minutes)
                  min_end_time = (catalyst_data.end_time.to_time-15.minutes)
                  max_end_time = (catalyst_data.end_time.to_time+15.minutes)
                  if (min_start_time..max_start_time).include?(schedule.start_time.to_time) && (min_end_time..max_end_time).include?(schedule.end_time.to_time)
                    schedule.update(start_time: catalyst_data.start_time, end_time: catalyst_data.end_time)
                    schedule.units = catalyst_data.units if schedule.units.present?
                    schedule.minutes = catalyst_data.minutes if schedule.minutes.present?
                    schedule.catalyst_data_ids.push(catalyst_data.id)
                    schedule.save(validate: false)
                    soap_note = schedule.soap_notes.new(add_date: catalyst_data.date, note: catalyst_data.note, creator_id: schedule.staff_id)
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
                    catalyst_data.system_scheduling_id = schedule.id
                    catalyst_data.multiple_schedulings_ids = []
                    catalyst_data.save
                    break
                  else
                    catalyst_data.multiple_schedulings_ids.push(schedule.id)
                    catalyst_data.multiple_schedulings_ids = catalyst_data.multiple_schedulings_ids.uniq
                    catalyst_data.save(validate: false)
                    response_data_hash[:system_data] = schedule
                    response_data_hash[:catalyst_data] = catalyst_data
                  end
                end
                catalyst_data.is_appointment_found = true
                catalyst_data.save(validate: false)
              else
                catalyst_data.is_appointment_found = false
                catalyst_data.save(validate: false)
                response_data_hash[:catalyst_data] = catalyst_data
              end
            end
            response_data_array.push(response_data_hash) if response_data_hash.any?
          end
        end
        response_data_array
      end
    end
  end
end
