json.status 'success'
json.data do
  json.array! @clinics do |clinic|
    json.partial! 'clinic_detail', clinic: clinic
  end
end
json.partial! 'pagination_detail', list: @clinics, page_number: params[:page]
