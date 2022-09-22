if @service.reload.errors.any?
  json.status 'failure'
  json.errors @service.errors.full_messages
else
  json.status 'success'
  json.data do
    json.partial! 'service_detail', service: @service
  end
end
