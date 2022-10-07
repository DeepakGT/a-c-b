json.status @staff_clinic.errors.any? ? 'failure' : 'success'
json.data do
  json.partial! 'staff_clinic_detail', staff_clinic: @staff_clinic
end
json.errors @staff_clinic.errors.full_messages&.map{|x| x.gsub('Is home clinic ', '')}
