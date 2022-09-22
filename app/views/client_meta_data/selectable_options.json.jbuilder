json.status 'success'
json.data do
  json.active_source_of_payment @client.client_enrollments.active.first&.source_of_payment
  json.services do
    json.array! @selectable_options[:services] do |service|
      json.partial! 'services/service_detail', service: service
    end
  end
end
