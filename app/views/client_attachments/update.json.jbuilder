json.status @attachment.errors.any? ? 'failure' : 'success'
json.data do
  json.partial! 'attachment_detail', attachment: @attachment
end
json.errors @attachment.errors.full_messages
