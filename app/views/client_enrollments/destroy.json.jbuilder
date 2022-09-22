if @client_enrollment.errors.any?
  json.status 'failure'
  json.errors @client_enrollment.errors.full_messages
else
  json.status 'success'
  json.data do
    json.partial! 'client_enrollment_detail', client_enrollment: @client_enrollment
  end
end
