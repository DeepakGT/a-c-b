json.status 'success'
json.data do
  json.array! @clinics do |clinic|
    json.partial! 'clinics/clinic_detail', clinic: clinic
  end
end
