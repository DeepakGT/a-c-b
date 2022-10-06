json.status @contact.errors.any? ? 'failure' : 'success'
json.data do
  json.partial! 'contact_detail', contact: @contact
end
json.errors @contact.errors.full_messages
