json.status 'success'
json.data do
  json.partial! 'attachment_detail', attachment: @attachment
end
