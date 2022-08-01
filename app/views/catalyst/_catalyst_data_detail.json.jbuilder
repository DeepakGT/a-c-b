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
json.id catalyst_data.id
json.client_name "#{client&.first_name} #{client&.last_name}"
json.client_id client&.id
json.staff_name "#{staff&.first_name} #{staff&.last_name}"
json.staff_id staff&.id
json.date "#{catalyst_data.date}"
json.start_time "#{catalyst_data.start_time}"
json.end_time "#{catalyst_data.end_time}"
json.units "#{catalyst_data.units}"
json.minutes "#{catalyst_data.minutes}"
json.note catalyst_data.note
json.location catalyst_data.session_location
json.cordinates catalyst_data.location
json.is_deleted_from_connect catalyst_data.is_deleted_from_connect
