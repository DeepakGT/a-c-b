json.status 'success'
json.data do
  json.array! @client_enrollments do |client_enrollment|
    json.id client_enrollment.funding_source&.id
    json.name client_enrollment.funding_source&.name
    if @service&.selected_payors.present?
      selected_payor = JSON.parse(@service&.selected_payors)&.select{|payor| payor['payor_id']==client_enrollment.funding_source&.id}&.first
      json.is_legacy_required selected_payor['is_legacy_required'] if (@service.is_service_provider_required.to_bool.true? && selected_payor.present?)
    end
  end
end
