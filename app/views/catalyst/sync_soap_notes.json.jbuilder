json.status @success ? 'success' : 'failure'
if @success
  json.message 'SOAP Notes syncing is being processing, please check after few time.'
else
  json.message 'SOAP Notes syncing is already in progress.'
end