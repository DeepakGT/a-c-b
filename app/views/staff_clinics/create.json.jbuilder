if @staff_clinic.errors.any?
  json.status 'failure'
  json.errors @staff_clinic.errors.full_messages
else
  json.status 'success'
  json.data do
    json.partial! 'staff_clinic_detail', staff_clinic: @staff_clinic
  end
end
