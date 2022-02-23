json.status 'success'
json.data do
  json.array! @staff_clinics do |staff_clinic|
    json.id staff_clinic.id
    json.clinic_id staff_clinic.clinic_id
    json.clinic_name staff_clinic.clinic.name
    json.organization_id staff_clinic.clinic.organization.id
    json.organization_name staff_clinic.clinic.organization.name
    json.is_home_clinic staff_clinic.is_home_clinic
    if staff_clinic.services.present? 
      json.services do
        # json.array! staff_clinic.services do |service|
        #   json.id service.id
        #   json.name service.name
        # end
        json.ids staff_clinic.services.pluck(:id)
        json.names staff_clinic.services.pluck(:name)
      end
    end
  end
end
