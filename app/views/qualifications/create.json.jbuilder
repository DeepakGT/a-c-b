if @qualification.errors.any?
  json.status 'failure'
  json.errors @qualification.errors.full_messages
else
  json.status 'success'
  json.data do
    json.partial! 'qualification_detail', qualification: @qualification
  end
end
