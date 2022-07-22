json.status 'success'
json.data do
  if @billable_funding_sources.present?
    json.billable_funding_sources do
      json.array! @billable_funding_sources do |funding_source|
        json.id funding_source.id
        json.name funding_source.name
      end
    end
  end
  if @non_billable_funding_sources.present?
    json.non_billable_funding_sources do
      json.array! @non_billable_funding_sources do |funding_source|
        json.id funding_source.id
        json.name funding_source.name
      end
    end
  end
  if @non_early_services.present?
    json.non_early_services do
      json.array! @non_early_services do |service|
        json.id service.id
        json.name service.name
      end
    end
  end
end
