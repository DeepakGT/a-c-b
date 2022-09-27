json.status 'success'
json.data do
  json.array! @bcbas do |bcba|
    staff_clinic = bcba.staff_clinics.order(is_home_clinic: :desc).first
    next if staff_clinic.clinic.nil?
    json.partial! 'staff/staff_detail', staff: bcba
    if staff_clinic.present?
      json.organization_id staff_clinic&.clinic&.organization_id
      json.organization_name staff_clinic&.clinic&.organization_name
      json.clinic_id staff_clinic&.clinic&.id
      json.clinic_name staff_clinic&.clinic&.name
    end
  end
end
