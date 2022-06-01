json.status 'success'
json.data do
  json.array! @staff do |staff|
    staff_clinic = staff.staff_clinics.order(is_home_clinic: :desc).first
    json.id staff.id
    json.first_name staff.first_name
    json.last_name staff.last_name
    json.email staff.email
    json.status staff.status
    json.hired_at staff.hired_at
    json.terminated_on staff.terminated_on
    json.title staff.role_name
    json.gender staff.gender
  end
end
