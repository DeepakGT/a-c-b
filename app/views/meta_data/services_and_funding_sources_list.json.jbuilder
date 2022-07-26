json.status 'success'
json.data do
  if @billable_funding_sources.present?
    json.funding_sources do
      json.array! @billable_funding_sources do |funding_source|
        json.partial! 'services_and_funding_sources_meta_data', data: funding_source
      end
    end
  end
  if @non_billable_funding_sources.present?
    json.funding_sources do
      json.array! @non_billable_funding_sources do |funding_source|
        json.partial! 'services_and_funding_sources_meta_data', data: funding_source
      end
    end
  end
  if @non_early_services.present?
    json.non_early_services do
      json.array! @non_early_services do |service|
        json.partial! 'services_and_funding_sources_meta_data', data: service
      end
    end
  end
end
