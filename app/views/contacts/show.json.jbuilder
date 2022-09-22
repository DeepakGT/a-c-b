json.status 'success'
json.data do
  json.partial! 'contact_detail', contact: @contact
end
