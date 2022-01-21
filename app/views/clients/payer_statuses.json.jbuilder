json.status 'success'
json.data do
  json.array! @payer_statuses do |payer_status|
    json.id payer_status.last
    json.type payer_status.first
  end
end
