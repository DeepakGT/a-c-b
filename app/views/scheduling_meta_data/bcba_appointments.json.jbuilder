json.status 'success'
json.data do
  json.setting_data Setting.first&.welcome_note

  json.todays_schedules do
    json.array! @todays_appointments do |schedule|
      json.partial! 'schedulings/scheduling_detail', schedule: schedule
    end
  end
  json.partial! 'exceeded_flags', past_schedules: @past_schedules
  json.client_enrollment_services do
    json.array! @client_enrollment_services do |client_enrollment_service|
      json.partial! 'client_enrollment_service_detail', client_enrollment_service: client_enrollment_service
    end
  end
  json.action_items do
    json.array! @action_items_array do |action_item|
      if action_item.type=='Schedule'
        json.type 'schedule'
        json.partial! 'schedulings/scheduling_detail', schedule: action_item
        if action_item.is_soap_notes_assigned==true
          if action_item.unrendered_reason.include?('units_does_not_match')
            catalyst_datas = CatalystData.where(id: action_item.catalyst_data_ids)
            json.catalyst_data do
              json.array! catalyst_datas do |catalyst_data|
                json.partial! 'catalyst/catalyst_data_detail', catalyst_data: catalyst_data
              end
            end
          else
            soap_note = action_item.soap_notes.last
            if soap_note.present?
              json.soap_note do 
                json.partial! 'soap_notes/soap_note_detail', soap_note: soap_note
              end
            end
          end
        else
          if action_item.soap_notes.where(synced_with_catalyst: false).present?
            json.soap_note do 
              soap_note = action_item.soap_notes.where(synced_with_catalyst: false).last
              json.partial! 'soap_notes/soap_note_detail', soap_note: soap_note
            end
          end
          if action_item.catalyst_data_ids.present?
            catalyst_datas = CatalystData.where(id: action_item.catalyst_data_ids) #.where(system_scheduling_id: action_item.id)
            if catalyst_datas.present?
              json.catalyst_data do
                json.array! catalyst_datas do |catalyst_data|
                  json.partial! 'catalyst/catalyst_data_detail', catalyst_data: catalyst_data
                end
              end
            end
          end
        end
        if !(action_item.unrendered_reason.include?('units_does_not_match')) && !(action_item.unrendered_reason.include?('soap_note_absent'))
          json.soap_note_id action_item.soap_notes.last.id if action_item.soap_notes.present?
          json.synced_with_catalyst action_item.soap_notes.last.synced_with_catalyst if action_item.soap_notes.present?
        end
      else
        json.type 'catalyst_data'
        json.partial! 'catalyst/catalyst_data_detail', catalyst_data: action_item
        json.unrendered_reasons ["no_appointment_found"] if action_item.system_scheduling_id.blank?
      end
    end
  end
end
json.partial! '/pagination_detail', list: @action_items_array, page_number: params[:page]
