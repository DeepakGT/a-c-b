json.status 'success'
json.data do
  json.partial! 'scheduling_detail', schedule: @schedule
  if @schedule.client_enrollment_service.present? && @schedule.client_enrollment_service.staff.present?
    json.partial! 'client_enrollment_services/service_provider_detail', enrollment_service: @schedule.client_enrollment_service, object_type: nil
  end
  if @schedule.catalyst_data_ids.present?
    json.catalyst_data do
      catalyst_datas = CatalystData.where(id: @schedule.catalyst_data_ids)
      json.array! catalyst_datas do |data|
        json.partial! 'catalyst/catalyst_data_detail'
      end
    end
  end
end
