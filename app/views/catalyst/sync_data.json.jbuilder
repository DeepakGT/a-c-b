json.status 'success'
json.data do
  json.array! @response_data_array do |response|
    if response[:catalyst_data].present?
      catalyst_data = response[:catalyst_data]
      json.catalyst_data do
        json.partial! 'catalyst_data_detail', catalyst_data: catalyst_data
      end
    end
    if response[:system_data].present?
      json.system_data do
        json.partial! 'schedulings/scheduling_detail', schedule: response[:system_data]
      end
    end
  end
end
