json.status 'success'
json.data do
  json.services do
    json.array! @selectable_options[:services] do |service|
      json.id service.id
      json.name service.name
    end
  end
  json.funding_sources do
    json.array! @selectable_options[:client_enrollments] do |client_enrollment|
      json.id client_enrollment.funding_source.id
      json.name client_enrollment.funding_source.name
    end
  end
  json.service_providers do
    json.array! @selectable_options[:service_providers] do |service_provider|
      json.id service_provider.staff.id
      json.name "#{service_provider.staff.first_name} #{service_provider.staff.last_name}"
      json.services do
        json.array! service_provider.services do |service|
          json.id service.id
        end
      end
    end
  end
end
