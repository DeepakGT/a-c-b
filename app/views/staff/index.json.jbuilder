json.status 'success'
json.data do
  json.array! @staff do |staff|
    json.partial! 'staff_detail', staff: staff
  end
end
json.show_inactive params[:show_inactive] if (params[:show_inactive] == 1 || params[:show_inactive] == "1")
json.search_cross_location params[:search_cross_location] if (params[:search_cross_location] == 1 || params[:search_cross_location] == "1")
json.partial! '/pagination_detail', list: @staff, page_number: params[:page]
