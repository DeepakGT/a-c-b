json.status 'success'
json.data do
  json.array! @response_data_array do |response|
    if response[:catalyst_data].present?
      json.catalyst_data do
        catalyst_data = response[:catalyst_data]
        json.client_name "#{catalyst_data.client_first_name} #{catalyst_data.client_last_name}"
        json.staff_name "#{catalyst_data.staff_first_name} #{catalyst_data.staff_last_name}"
        json.date "#{catalyst_data.date}"
        json.start_time "#{catalyst_data.start_time}"
        json.end_time "#{catalyst_data.end_time}"
      end
    end
    if response[:system_data].present?
      json.system_data do
        schedule = response[:system_data]
        client = schedule&.client_enrollment_service&.client_enrollment&.client
        json.client_name "#{client&.first_name} #{client&.last_name}"
        json.staff_name "#{schedule&.staff&.first_name} #{schedule&.staff&.last_name}"
        json.date schedule&.date
        json.start_time schedule&.start_time
        json.end_time schedule&.end_time
      end
    end
  end
end
