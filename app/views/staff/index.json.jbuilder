json.status 'success'
json.data do
  json.array! @staff do |staff|
    staff_clinic = staff.staff_clinics.order(is_home_clinic: :desc).first
    json.partial! 'staff_detail', staff: staff
    if staff_clinic.present?
      json.organization_id staff_clinic.clinic&.organization_id
      json.organization_name staff_clinic.clinic&.organization_name
      json.clinic_id staff_clinic.clinic_id
      json.clinic_name staff_clinic.clinic&.name
    end
    json.phone staff.phone_numbers.first&.number
  end
end
json.show_inactive params[:show_inactive] if (params[:show_inactive] == 1 || params[:show_inactive] == "1")
json.search_cross_location params[:search_cross_location] if (params[:search_cross_location] == 1 || params[:search_cross_location] == "1")
json.partial! 'pagination_detail', list: @staff, page_number: params[:page]
