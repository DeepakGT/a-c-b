json.status 'success'
json.data do
  json.array! @attachments do |attachment|
    next if attachment.role_permissions.present? && !attachment.role_permissions.include?(current_user.role_name)

    json.partial! 'attachment_detail', attachment: attachment
  end
end
