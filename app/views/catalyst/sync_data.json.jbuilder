json.status 'success'
json.data do
  json.array! @response_data_array do |response|
    if response[:catalyst_data].present?
      catalyst_data = response[:catalyst_data]
      staff = Staff.where(catalyst_user_id: catalyst_data.catalyst_user_id)
      if staff.count==1
        staff = staff.first
      elsif staff.count>1
        staff = staff.find_by(status: 'active')
      else
        staff = Staff.find_by(catalyst_user_id: catalyst_data.catalyst_user_id)
      end
      client = Client.where(catalyst_patient_id: catalyst_data.catalyst_patient_id)
      if client.count==1
        client = client.first
      elsif client.count>1
        client = client.find_by(status: 'active')
      else
        client = Client.find_by(catalyst_patient_id: catalyst_data.catalyst_patient_id)
      end
      json.catalyst_data do
        json.id catalyst_data.id
        json.client_id client&.id
        json.client_name "#{client&.first_name} #{client&.last_name}"
        json.staff_id staff&.id
        json.staff_name "#{staff&.first_name} #{staff&.last_name}"
        json.date "#{catalyst_data.date}"
        json.start_time "#{catalyst_data.start_time}"
        json.end_time "#{catalyst_data.end_time}"
      end
    end
    if response[:system_data].present?
      json.system_data do
        schedule = response[:system_data]
        client = schedule&.client_enrollment_service&.client_enrollment&.client
        json.id schedule.id
        json.client_name "#{client&.first_name} #{client&.last_name}"
        json.staff_name "#{schedule&.staff&.first_name} #{schedule&.staff&.last_name}"
        json.date schedule&.date
        json.start_time schedule&.start_time
        json.end_time schedule&.end_time
      end
    end
  end
end
