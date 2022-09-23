json.status 'success'
json.data do
  if @billable_funding_sources.present?
    json.funding_sources do
      json.partial! 'list_detail_with_name', list: @billable_funding_sources
    end
  end
  if @non_billable_funding_sources.present?
    json.funding_sources do
      json.partial! 'list_detail_with_name', list: @non_billable_funding_sources
    end
  end
  if @non_early_services.present?
    json.non_early_services do
      json.partial! 'list_detail_with_name', list: @non_early_services
    end
  end
end
