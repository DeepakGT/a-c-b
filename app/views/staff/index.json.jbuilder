json.status 'success'
json.data do
  json.array! @staff do |staff|
    staff_clinic = staff.staff_clinics.order(is_home_clinic: :desc).first
    json.id staff.id
    json.first_name staff.first_name
    json.last_name staff.last_name
    json.email staff.email
    json.title staff.role_name
    json.job_type staff.job_type
    json.hired_at staff.hired_at
    json.terminated_on staff.terminated_on
    if staff_clinic.present?
      json.organization_id staff_clinic.clinic&.organization_id
      json.organization_name staff_clinic.clinic&.organization_name
      json.clinic_id staff_clinic.clinic_id
      json.clinic_name staff_clinic.clinic&.name
    end
    json.status staff.status
    if staff.supervisor.present?
      json.supervisor_id staff.supervisor_id
      json.immediate_supervisor "#{staff.supervisor&.first_name} #{staff.supervisor&.last_name}"
    end
    json.phone staff.phone_numbers.first&.number
    json.phone_numbers do
      json.array! staff.phone_numbers do |phone|
        json.id phone.id
        json.phone_type phone.phone_type
        json.number phone.number
      end
    end
    if staff.address.present?
      json.address do
        json.id staff.address.id
        json.line1 staff.address.line1
        json.line2 staff.address.line2
        json.line3 staff.address.line3
        json.zipcode staff.address.zipcode
        json.city staff.address.city
        json.state staff.address.state
        json.country staff.address.country
      end
    end
  end
end
if params[:show_inactive] == 1 || params[:show_inactive] == "1"
  json.show_inactive params[:show_inactive]
end
json.total_records @staff.total_entries
json.limit @staff.per_page
json.page params[:page] || 1
