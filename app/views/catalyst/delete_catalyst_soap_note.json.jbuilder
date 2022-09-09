json.status @catalyst_data.errors.any? ? 'failure' : 'success'
json.data do
  json.partial! 'catalyst_data_detail', catalyst_data: @catalyst_data
end
