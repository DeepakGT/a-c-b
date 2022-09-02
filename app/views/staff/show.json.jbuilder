json.status 'success'
json.data do
  json.partial! 'staff_detail', staff: @staff
end
