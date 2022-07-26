json.status 'success'
json.data do
  if @billable_funding_sources.present?
    json.funding_sources do
      json.partial! 'services_and_funding_sources_meta_data', list: @billable_funding_sources
    end
  end
  if @non_billable_funding_sources.present?
    json.funding_sources do
      json.partial! 'services_and_funding_sources_meta_data', list: @non_billable_funding_sources
    end
  end
  if @non_early_services.present?
    json.non_early_services do
      json.partial! 'services_and_funding_sources_meta_data', list: @non_early_services
    end
  end
end
