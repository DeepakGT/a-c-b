json.status 'success'
json.data do
  json.array! @contacts do |contact|
    json.partial! 'contact_detail', contact: contact
  end
end
json.partial! 'pagination_detail', list: @contacts, page_number: params[:page]
