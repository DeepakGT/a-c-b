json.status 'success'
json.data do
  json.array! @user_clinics do |user_clinic|
    json.clinic_id user_clinic.clinic_id
    json.clinic_name user_clinic.clinic.name
    json.organization_id user_clinic.organization.id
    json.organization_name user_clinic.clinic.organization.name
    json.is_home_clinic user_clinic.is_home_clinic
  end
end
