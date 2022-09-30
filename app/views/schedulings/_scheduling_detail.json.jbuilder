client = schedule.client_enrollment_service&.client_enrollment&.client
service = schedule.client_enrollment_service&.service
json.id schedule.id
json.client_enrollment_service_id schedule.client_enrollment_service_id
json.cross_site_allowed schedule.cross_site_allowed
json.client_id client&.id
json.client_name "#{client.first_name} #{client.last_name}" if client.present?
json.service_address_id schedule.service_address_id
json.allow_soap_notes_from_connect schedule&.client_enrollment_service&.service&.allow_soap_notes_from_connect
json.service_address schedule.service_address

if schedule.client_enrollment_service_id.present?
  json.total_units schedule.client_enrollment_service.units
  json.used_units schedule.client_enrollment_service.used_units
  json.scheduled_units schedule.client_enrollment_service.scheduled_units
  json.left_units schedule.client_enrollment_service.left_units
  json.total_minutes schedule.client_enrollment_service.minutes
  json.used_minutes schedule.client_enrollment_service.used_minutes
  json.scheduled_minutes schedule.client_enrollment_service.scheduled_minutes
  json.left_minutes schedule.client_enrollment_service.left_minutes
end

json.staff_id schedule.staff_id
json.staff_name "#{schedule.staff.first_name} #{schedule.staff.last_name}" if schedule.staff.present?
json.staff_role schedule&.staff&.role_name if schedule&.staff.present?
json.staff_email schedule.staff.email if schedule.staff.present?
json.staff_legacy_number schedule.staff.legacy_number if schedule.staff.present?

if @schedule&.client_enrollment_service_id.present? && @schedule.client_enrollment_service.service&.selected_payors.present?
  selected_payor = JSON.parse(schedule&.client_enrollment_service&.service&.selected_payors)&.select{|payor| payor['payor_id']==schedule&.client_enrollment_service&.client_enrollment&.funding_source&.id}&.first
  json.is_legacy_required selected_payor['is_legacy_required'] if (schedule&.client_enrollment_service&.service&.is_service_provider_required? && selected_payor.present?)
end

json.service_id service&.id
json.service_name service&.name
json.service_display_code service&.display_code 
json.is_early_code service.is_early_code
json.status I18n.t("activerecord.attributes.scheduling.statuses.#{schedule.status}").capitalize if schedule.status.present?
json.date schedule.date
json.start_time schedule.start_time&.in_time_zone&.strftime("%I:%M %p")
json.end_time schedule.end_time&.in_time_zone&.strftime("%I:%M %p")
json.non_billable_reason schedule.non_billable_reason

if schedule.rendered_at.present? && schedule.status == 'rendered'
  json.is_rendered true
else
  json.is_rendered false
end

json.is_manual_render schedule.is_manual_render
rendered_by_staff = User.find_by(id: schedule.rendered_by_id)
json.rendered_by "#{rendered_by_staff&.first_name} #{rendered_by_staff&.last_name}"
json.unrendered_reasons schedule.unrendered_reason
json.rendered_at schedule.rendered_at
json.units schedule.units
json.minutes schedule.minutes
json.created_at schedule.created_at
json.appointment_office_id schedule&.appointment_office_id
json.appointment_office Clinic.find_by(id: schedule&.appointment_office_id)&.name

if schedule.creator_id.present?
  creator = User.find_by(id: schedule.creator_id)
  json.creator_id schedule.creator_id
  json.creator_name "#{creator&.first_name} #{creator&.last_name}"
else
  json.creator_id nil
  json.creator_name nil
end

if schedule.updator_id.present?
  updator = User.find_by(id: schedule.updator_id)
  json.updator_id schedule.updator_id
  json.updator_name "#{updator&.first_name} #{updator&.last_name}"
else
  json.updator_id nil
  json.updator_name nil
end
