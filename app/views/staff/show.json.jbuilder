json.status 'success'
json.data do
  staff_clinic = @staff.staff_clinics.order(is_home_clinic: :desc).first
  json.partial! 'staff_detail', staff: @staff
  if staff_clinic.present?
    json.organization_id staff_clinic.clinic&.organization_id
    json.organization_name staff_clinic.clinic&.organization_name
    json.clinic_id staff_clinic.clinic_id
    json.clinic_name staff_clinic.clinic&.name
  end
end
json.billable_hours @staff.billable_hours_for_current_week if @staff.type=='Staff'
