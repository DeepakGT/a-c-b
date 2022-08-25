json.status 'success'
json.data do
  json.array! @qualifications do |qualification|
    json.partial! 'staff_qualification_detail', staff_qualification: qualification
  end
end
