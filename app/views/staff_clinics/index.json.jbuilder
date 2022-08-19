json.status 'success'
json.data do
  json.array! @staff_clinics do |staff_clinic|
    json.partial! 'staff_clinic_detail', staff_clinic: @staff_clinic
  end
end
