json.status 'success'
json.data do
  json.array! @qualifications do |qualification|
    json.partial! 'qualification_detail', qualification: qualification
  end
end
json.partial! '/pagination_detail', list: @qualifications, page_number: params[:page]
