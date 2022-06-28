json.status 'success'
json.data do
  client = @schedule.client_enrollment_service&.client_enrollment&.client
  service = @schedule.client_enrollment_service&.service
  json.id @schedule.id
  json.client_enrollment_service_id @schedule.client_enrollment_service_id
  if @schedule.client_enrollment_service_id.present?
    json.total_units @schedule.client_enrollment_service.units
    json.used_units @schedule.client_enrollment_service.used_units
    json.scheduled_units @schedule.client_enrollment_service.scheduled_units
    json.left_units @schedule.client_enrollment_service.left_units
    json.total_minutes @schedule.client_enrollment_service.minutes
    json.used_minutes @schedule.client_enrollment_service.used_minutes
    json.scheduled_minutes @schedule.client_enrollment_service.scheduled_minutes
    json.left_minutes @schedule.client_enrollment_service.left_minutes
  end
  json.cross_site_allowed @schedule.cross_site_allowed
  json.client_id client&.id
  json.client_name "#{client.first_name} #{client.last_name}" if client.present?
  json.service_address_id @schedule.service_address_id
  if @schedule.service_address_id.present?
    service_address = Address.find_by(id: @schedule.service_address_id)
    if service_address.present?
      json.service_address do
        json.line1 service_address.line1
        json.line2 service_address.line2
        json.line3 service_address.line3
        json.zipcode service_address.zipcode
        json.city service_address.city
        json.state service_address.state
        json.country service_address.country
        json.is_default service_address.is_default
        json.address_name service_address.address_name
      end
    end
  end
  json.staff_id @schedule.staff_id
  json.staff_name "#{@schedule.staff.first_name} #{@schedule.staff.last_name}" if @schedule.staff.present?
  json.staff_role @schedule.staff.role_name if @schedule.staff.present?
  json.staff_email @schedule.staff.email if @schedule.staff.present?
  json.service_id service&.id
  json.service_name service&.name
  json.service_display_code service&.display_code 
  json.status @schedule.status
  json.date @schedule.date
  json.start_time @schedule.start_time.to_time.strftime('%H:%M')
  json.end_time @schedule.end_time.to_time.strftime('%H:%M')
  if @schedule.rendered_at.present?
    json.is_rendered true
  else
    json.is_rendered false
  end
  json.is_manual_render @schedule.is_manual_render
  json.unrendered_reasons @schedule.unrendered_reason
  json.rendered_at @schedule.rendered_at
  json.units @schedule.units
  json.minutes @schedule.minutes
  if @schedule.client_enrollment_service.present? && @schedule.client_enrollment_service.staff.present?
    json.service_providers do
      json.array! @schedule.client_enrollment_service.staff do |staff|
        json.id staff.id
        json.name "#{staff.first_name} #{staff.last_name}"
        json.role staff.role_name
      end
    end
  end
  if @schedule.creator_id.present?
    creator = User.find_by(id: @schedule.creator_id)
    json.creator_id @schedule.creator_id
    json.creator_name "#{creator&.first_name} #{creator&.last_name}"
  else
    json.creator_id nil
    json.creator_name nil
  end
  if @schedule.updator_id.present?
    updator = User.find_by(id: @schedule.updator_id)
    json.updator_id @schedule.updator_id
    json.updator_name "#{updator&.first_name} #{updator&.last_name}"
  else
    json.updator_id nil
    json.updator_name nil
  end
  if @schedule.catalyst_data_ids.present?
    json.catalyst_data do
      catalyst_datas = CatalystData.where(id: @schedule.catalyst_data_ids)
      json.array! catalyst_datas do |data|
        user = Staff.where(catalyst_user_id: data.catalyst_user_id)
        if user.count==1
            user = user.first
        elsif user.count>1
            user = user.find_by(status: 'active')
        else
            user = Staff.find_by(catalyst_user_id: data.catalyst_user_id)
        end
        patient = Client.where(catalyst_patient_id: data.catalyst_patient_id)
        if patient.count==1
            patient = patient.first
        elsif patient.count>1
            patient = patient.find_by(status: 'active')
        else
            patient = patient.find_by(catalyst_patient_id: data.catalyst_patient_id)
        end
        json.id data.id
        json.client_name "#{patient&.first_name} #{patient&.last_name}"
        json.client_id patient&.id
        json.staff_name "#{user&.first_name} #{user&.last_name}"
        json.staff_id user&.id
        json.date "#{data.date}"
        json.start_time "#{data.start_time}"
        json.end_time "#{data.end_time}"
        json.units "#{data.units}"
        json.minutes "#{data.minutes}"
        json.note data.note
      end
    end
  end
end