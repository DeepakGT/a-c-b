json.status 'success'
json.data do
  json.array! @staff do |staff|
    json.id staff.id
    json.first_name staff.first_name
    json.last_name staff.last_name
    json.title staff.role_name
    json.organization_id staff.clinic.organization_id
    json.organization_name staff.clinic.organization_name
    json.clinic_id staff.clinic_id
    json.clinic_name staff.clinic.name
    if staff.supervisor.present?
      json.supervisor_id staff.supervisor_id
      json.immediate_supervisor "#{staff.supervisor.first_name} #{staff.supervisor.last_name}"
    end
    json.phone staff.phone_numbers.first&.number
  end
end
json.total_records @staff.total_entries
json.limit @staff.per_page
json.page params[:page] || 1
