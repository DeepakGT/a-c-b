json.status @staff.errors.any? ? 'failure' : 'success'
json.data do
  json.partial! 'staff_detail', staff: @staff
end
json.errors @staff.errors.full_messages&.map{|x| x.gsub('Address ', '')}
