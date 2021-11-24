json.status 'success'
json.data do
  json.array! @staff do |staff|
    json.id staff.id
    json.first_name staff.first_name
    json.last_name staff.last_name
    json.title staff.role_name
    json.department staff.user_role.department
    if staff.supervisor.blank?
      json.immediate_supervisor ''
    else
      json.immediate_supervisor "#{staff.supervisor.first_name} #{staff.supervisor.last_name}"
    end
    json.phone staff.phone_numbers.first&.number
    json.extension staff.phone_ext
    json.hired_at staff.hired_at
  end
end
json.total_records @staff.total_entries
json.limit @staff.per_page
json.page params[:page]
