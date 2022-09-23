if @staff_qualification.errors.any?
  json.status 'failure'
  json.errors @staff_qualification.errors.full_messages
else
  json.status 'success'
  json.data do
    json.partial! 'staff_qualification_detail', staff_qualification: @staff_qualification
  end
end
