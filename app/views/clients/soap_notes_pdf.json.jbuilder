if @success
  json.status 'success'
  json.message 'Pdf generation is in progress. Please check your email after sometime.'
else
  json.status 'failure'
  json.message 'Pdf generation cannot be processed. Please try again!'
end
