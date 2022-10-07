json.status 'success'
json.data do
  json.partial! 'staff_clinic_detail', staff_clinic: @staff_clinic
end
