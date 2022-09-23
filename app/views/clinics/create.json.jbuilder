json.status @clinic.errors.any? ? 'failure' : 'success'
json.data do
  json.partial! 'clinic_detail', clinic: @clinic
end
json.errors @clinic.errors.full_messages&.map{|x| x.gsub('Address ', '')}
