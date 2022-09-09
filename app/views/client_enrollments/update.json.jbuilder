json.status @client_enrollment.errors.any? ? 'failure' : 'success'
json.data do
  json.partial! 'client_enrollment_detail', client_enrollment: @client_enrollment
end
json.errors @client_enrollment.errors.full_messages
