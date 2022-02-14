json.status 'success'
json.data do
  json.array! @staff do |staff|
    user_clinic = staff.user_clinics.order(is_home_clinic: :desc).first
    json.id staff.id
    json.first_name staff.first_name
    json.last_name staff.last_name
    json.email staff.email
    json.title staff.role_name
    if user_clinic.present?
      json.organization_id user_clinic.clinic.organization_id
      json.organization_name user_clinic.clinic.organization_name
      json.clinic_id user_clinic.clinic_id
      json.clinic_name user_clinic.clinic.name
    end
    json.status staff.status
    if staff.supervisor.present?
      json.supervisor_id staff.supervisor_id
      json.immediate_supervisor "#{staff.supervisor.first_name} #{staff.supervisor.last_name}"
    end
    json.phone staff.phone_numbers.first&.number
    json.phone_numbers do
      json.array! staff.phone_numbers do |phone|
        json.id phone.id
        json.phone_type phone.phone_type
        json.number phone.number
      end
    end
  end
end
json.total_records @staff.total_entries
json.limit @staff.per_page
json.page params[:page] || 1
