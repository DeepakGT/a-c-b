json.status 'success'
json.data do
  json.array! @attachments do |attachment|
    json.partial! 'attachment_detail', attachment: attachment
  end
end
