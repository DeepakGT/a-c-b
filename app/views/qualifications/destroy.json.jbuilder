json.status @qualification.errors.any? ? 'failure' : 'success'
json.data do
  json.partial! 'qualification_detail', qualification: @qualification
end
json.errors @qualification.errors.full_messages
