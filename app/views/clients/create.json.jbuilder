json.status @client.errors.any? ? 'failure' : 'success'
json.data do
  json.partial! 'client_detail', client: @client
end
json.errors @client.errors.full_messages&.map{|x| x.gsub('Address ', '')}
