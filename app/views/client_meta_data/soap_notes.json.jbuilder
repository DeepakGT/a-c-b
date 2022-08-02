json.status 'success'
json.data do
  json.array! @soap_notes do |soap_note|
    json.partial! 'soap_notes/soap_note_detail', soap_note: soap_note
  end
end
json.partial! 'pagination_detail', list: @soap_notes, page_number: params[:page]
