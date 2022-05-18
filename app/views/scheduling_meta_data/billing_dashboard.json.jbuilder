json.status 'success'
json.data do
  json.setting_data Setting.first&.welcome_note

  json.authorizations_expire_in_5_days do
    json.array! @authorizations_expire_in_5_days do |client_enrollment_service|
      client = client_enrollment_service.client_enrollment&.client
      schedules = Scheduling.by_client_and_service(client_enrollment_service.client_enrollment.client_id, client_enrollment_service.service_id)
      schedules = schedules.with_rendered_or_scheduled_as_status
      completed_schedules = schedules.completed_scheduling
      scheduled_schedules = schedules.scheduled_scheduling
      used_units = completed_schedules.with_units.pluck(:units).sum
      scheduled_units = scheduled_schedules.with_units.pluck(:units).sum
      used_minutes = completed_schedules.with_minutes.pluck(:minutes).sum
      scheduled_minutes = scheduled_schedules.with_minutes.pluck(:minutes).sum
      json.id client_enrollment_service.id
      json.client_id client_enrollment_service.client_enrollment&.client_id
      json.client_name "#{client&.first_name} #{client&.last_name}"
      json.client_enrollment_id client_enrollment_service.client_enrollment_id
      json.funding_source_id client_enrollment_service.client_enrollment.funding_source_id
      json.funding_source client_enrollment_service.client_enrollment.funding_source&.name
      json.service_id client_enrollment_service.service_id
      json.service client_enrollment_service.service&.name
      json.service_display_code client_enrollment_service.service&.display_code
      json.is_service_provider_required client_enrollment_service.service&.is_service_provider_required
      json.start_date client_enrollment_service.start_date
      json.end_date client_enrollment_service.end_date
      json.units client_enrollment_service.units
      json.used_units used_units
      json.scheduled_units scheduled_units
      if client_enrollment_service.units.present?
        json.left_units client_enrollment_service.units - (used_units + scheduled_units) 
      else
        json.left_units 0
      end
      json.minutes client_enrollment_service.minutes
      json.used_minutes used_minutes
      json.scheduled_minutes scheduled_minutes
      if client_enrollment_service.minutes.present?
        json.left_minutes client_enrollment_service.minutes - (used_minutes + scheduled_minutes)
      else
        json.left_minutes 0
      end
      json.service_number client_enrollment_service.service_number
      json.service_providers do
        json.ids client_enrollment_service.service_providers.pluck(:id)
        json.staff_ids client_enrollment_service.service_providers.pluck(:staff_id)
        json.names client_enrollment_service.staff&.map{|staff| "#{staff.first_name} #{staff.last_name}"}
      end
    end
  end
  json.authorizations_renewal_in_5_to_20_days do
    json.array! @authorizations_renewal_in_5_to_20_days do |client_enrollment_service|
      client = client_enrollment_service.client_enrollment&.client
      schedules = Scheduling.by_client_and_service(client_enrollment_service.client_enrollment.client_id, client_enrollment_service.service_id)
      schedules = schedules.with_rendered_or_scheduled_as_status
      completed_schedules = schedules.completed_scheduling
      scheduled_schedules = schedules.scheduled_scheduling
      used_units = completed_schedules.with_units.pluck(:units).sum
      scheduled_units = scheduled_schedules.with_units.pluck(:units).sum
      used_minutes = completed_schedules.with_minutes.pluck(:minutes).sum
      scheduled_minutes = scheduled_schedules.with_minutes.pluck(:minutes).sum
      json.id client_enrollment_service.id
      json.client_id client_enrollment_service.client_enrollment&.client_id
      json.client_name "#{client&.first_name} #{client&.last_name}"
      json.client_enrollment_id client_enrollment_service.client_enrollment_id
      json.funding_source_id client_enrollment_service.client_enrollment.funding_source_id
      json.funding_source client_enrollment_service.client_enrollment.funding_source&.name
      json.service_id client_enrollment_service.service_id
      json.service client_enrollment_service.service&.name
      json.service_display_code client_enrollment_service.service&.display_code
      json.is_service_provider_required client_enrollment_service.service&.is_service_provider_required
      json.start_date client_enrollment_service.start_date
      json.end_date client_enrollment_service.end_date
      json.units client_enrollment_service.units
      json.used_units used_units
      json.scheduled_units scheduled_units
      if client_enrollment_service.units.present?
        json.left_units client_enrollment_service.units - (used_units + scheduled_units) 
      else
        json.left_units 0
      end
      json.minutes client_enrollment_service.minutes
      json.used_minutes used_minutes
      json.scheduled_minutes scheduled_minutes
      if client_enrollment_service.minutes.present?
        json.left_minutes client_enrollment_service.minutes - (used_minutes + scheduled_minutes)
      else
        json.left_minutes 0
      end
      json.service_number client_enrollment_service.service_number
      json.service_providers do
        json.ids client_enrollment_service.service_providers.pluck(:id)
        json.staff_ids client_enrollment_service.service_providers.pluck(:staff_id)
        json.names client_enrollment_service.staff&.map{|staff| "#{staff.first_name} #{staff.last_name}"}
      end
    end
  end
  json.authorizations_renewal_in_21_to_60_days do
    json.array! @authorizations_renewal_in_21_to_60_days do |client_enrollment_service|
      client = client_enrollment_service.client_enrollment&.client
      schedules = Scheduling.by_client_and_service(client_enrollment_service.client_enrollment.client_id, client_enrollment_service.service_id)
      schedules = schedules.with_rendered_or_scheduled_as_status
      completed_schedules = schedules.completed_scheduling
      scheduled_schedules = schedules.scheduled_scheduling
      used_units = completed_schedules.with_units.pluck(:units).sum
      scheduled_units = scheduled_schedules.with_units.pluck(:units).sum
      used_minutes = completed_schedules.with_minutes.pluck(:minutes).sum
      scheduled_minutes = scheduled_schedules.with_minutes.pluck(:minutes).sum
      json.id client_enrollment_service.id
      json.client_id client_enrollment_service.client_enrollment&.client_id
      json.client_name "#{client&.first_name} #{client&.last_name}"
      json.client_enrollment_id client_enrollment_service.client_enrollment_id
      json.funding_source_id client_enrollment_service.client_enrollment.funding_source_id
      json.funding_source client_enrollment_service.client_enrollment.funding_source&.name
      json.service_id client_enrollment_service.service_id
      json.service client_enrollment_service.service&.name
      json.service_display_code client_enrollment_service.service&.display_code
      json.is_service_provider_required client_enrollment_service.service&.is_service_provider_required
      json.start_date client_enrollment_service.start_date
      json.end_date client_enrollment_service.end_date
      json.units client_enrollment_service.units
      json.used_units used_units
      json.scheduled_units scheduled_units
      if client_enrollment_service.units.present?
        json.left_units client_enrollment_service.units - (used_units + scheduled_units) 
      else
        json.left_units 0
      end
      json.minutes client_enrollment_service.minutes
      json.used_minutes used_minutes
      json.scheduled_minutes scheduled_minutes
      if client_enrollment_service.minutes.present?
        json.left_minutes client_enrollment_service.minutes - (used_minutes + scheduled_minutes)
      else
        json.left_minutes 0
      end
      json.service_number client_enrollment_service.service_number
      json.service_providers do
        json.ids client_enrollment_service.service_providers.pluck(:id)
        json.staff_ids client_enrollment_service.service_providers.pluck(:staff_id)
        json.names client_enrollment_service.staff&.map{|staff| "#{staff.first_name} #{staff.last_name}"}
      end
    end
  end
  json.client_with_no_authorizations do
    json.array! @client_with_no_authorizations do |client|
      primary_client_enrollment = client.client_enrollments.active&.order(is_primary: :desc)&.first
      json.id client.id
      json.first_name client.first_name
      json.last_name client.last_name
      json.email client.email
      json.clinic_id client.clinic_id
      json.clinic_name client.clinic.name
      json.bcba_id client.bcba_id
      json.bcba_name "#{client.bcba&.first_name} #{client.bcba&.last_name}"
      json.email client.email
      json.dob client.dob
      json.gender client.gender
      json.status client.status
      json.tracking_id client.tracking_id
      json.preferred_language client.preferred_language
      json.disqualified client.disqualified
      json.disqualified_reason client.dq_reason if client.disqualified?
      json.payor_status client.payor_status
      if primary_client_enrollment.present?
        if primary_client_enrollment.source_of_payment=='self_pay' || primary_client_enrollment.funding_source.blank?
          json.payor nil
        else
          json.payor primary_client_enrollment.funding_source.name
        end
      end
      if client.addresses.present?
        json.addresses do
          json.array! client.addresses do |address|
            json.id address.id
            json.type address.address_type
            json.line1 address.line1
            json.line2 address.line2
            json.line3 address.line3
            json.zipcode address.zipcode
            json.city address.city
            json.state address.state
            json.country address.country
            json.is_default address.is_default if address.address_type=='service_address'
          end
        end
      end
      if client.phone_number.present?
        json.phone_number do
          json.id client.phone_number.id
          json.phone_type client.phone_number.phone_type
          json.number client.phone_number.number
        end
      end
    end
  end
  json.client_with_only_97151_service_authorization do
    json.array! @client_with_only_97151_service_authorization do |client|
      primary_client_enrollment = client.client_enrollments.active&.order(is_primary: :desc)&.first
      json.id client.id
      json.first_name client.first_name
      json.last_name client.last_name
      json.email client.email
      json.clinic_id client.clinic_id
      json.clinic_name client.clinic.name
      json.bcba_id client.bcba_id
      json.bcba_name "#{client.bcba&.first_name} #{client.bcba&.last_name}"
      json.email client.email
      json.dob client.dob
      json.gender client.gender
      json.status client.status
      json.tracking_id client.tracking_id
      json.preferred_language client.preferred_language
      json.disqualified client.disqualified
      json.disqualified_reason client.dq_reason if client.disqualified?
      json.payor_status client.payor_status
      if primary_client_enrollment.present?
        if primary_client_enrollment.source_of_payment=='self_pay' || primary_client_enrollment.funding_source.blank?
          json.payor nil
        else
          json.payor primary_client_enrollment.funding_source.name
        end
      end
      if client.addresses.present?
        json.addresses do
          json.array! client.addresses do |address|
            json.id address.id
            json.type address.address_type
            json.line1 address.line1
            json.line2 address.line2
            json.line3 address.line3
            json.zipcode address.zipcode
            json.city address.city
            json.state address.state
            json.country address.country
            json.is_default address.is_default if address.address_type=='service_address'
          end
        end
      end
      if client.phone_number.present?
        json.phone_number do
          json.id client.phone_number.id
          json.phone_type client.phone_number.phone_type
          json.number client.phone_number.number
        end
      end
    end
  end
end
