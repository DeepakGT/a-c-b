if @contact.errors.any?
  json.status 'failure'
  json.errors @contact.errors.full_messages
else
  json.status 'success'
  json.data do
    json.partial! 'contact_detail', contact: @contact
  end
end
