if @staff.errors.any?
  json.status 'failure'
  json.errors @staff.errors.full_messages
else
  json.status 'success'
  json.data do
    json.partial! 'staff_detail', staff: @staff
  end
end
