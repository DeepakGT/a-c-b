json.status 'success'
json.data do
  json.array! @dq_reasons do |dq_reason|
    json.id dq_reason.last
    json.type dq_reason.first
  end
end
