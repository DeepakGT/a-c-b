json.status 'success'
json.data do
  json.partial! 'qualification_detail', qualification: @qualification
end
