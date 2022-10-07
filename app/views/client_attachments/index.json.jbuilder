json.status 'success'
json.data do
  json.array! @attachments do |attachment|
    next unless attachment.can_be_displayed?(current_user.role_name)

    json.partial! 'attachment_detail', attachment: attachment
  end
end
