json.status 'success'
json.data do
  json.active_source_of_payment @client.client_enrollments.active.first&.source_of_payment
  json.services do
    json.array! @selectable_options[:services] do |service|
      json.id service.id
      json.name service.name
      json.display_code service.display_code
      json.is_early_code service&.is_early_code
      json.is_service_provider_required service.is_service_provider_required
    end
  end
  json.funding_sources do
    json.array! @selectable_options[:client_enrollments] do |client_enrollment|
      json.id client_enrollment.funding_source&.id
      json.name client_enrollment.funding_source&.name
    end
  end
end
