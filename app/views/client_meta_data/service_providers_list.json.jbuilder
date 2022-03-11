json.status 'success'
json.data do
  json.array! @staff do |staff|
    json.id staff.id
    json.name "#{staff.first_name} #{staff.last_name}"
  end
end
