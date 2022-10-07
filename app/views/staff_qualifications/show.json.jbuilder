json.status 'success'
json.data do
  json.partial! 'staff_qualification_detail', staff_qualification: @staff_qualification
end
