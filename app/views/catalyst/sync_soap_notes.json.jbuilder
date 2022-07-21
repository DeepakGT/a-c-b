json.status @success ? 'success' : 'failure'
if @success
  json.message 'SOAP Notes syncing in progress.'
else
  json.message 'SOAP Notes syncing is already in progress.'
end
