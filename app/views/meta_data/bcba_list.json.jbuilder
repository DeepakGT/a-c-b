json.status 'success'
json.data do
  json.array! @bcbas do |bcba|
    staff_clinic = bcba.staff_clinics.order(is_home_clinic: :desc).first
    json.id bcba.id
    json.first_name bcba.first_name
    json.last_name bcba.last_name
    json.email bcba.email
    json.status bcba.status
    json.hired_at bcba.hired_at
    json.terminated_on bcba.terminated_on
    json.title bcba.role_name
    json.gender bcba.gender
    json.legacy_number bcba.legacy_number
    if staff_clinic.present?
      json.organization_id staff_clinic.clinic&.organization_id
      json.organization_name staff_clinic.clinic&.organization_name
      json.clinic_id staff_clinic.clinic_id
      json.clinic_name staff_clinic.clinic&.name
    end
    if bcba.supervisor.present?
      json.supervisor_id bcba.supervisor_id
      json.immediate_supervisor "#{bcba.supervisor&.first_name} #{bcba.supervisor&.last_name}"
    end
    json.phone_numbers do
      json.array! bcba.phone_numbers do |phone|
        json.id phone.id
        json.phone_type phone.phone_type
        json.number phone.number
      end
    end
    if bcba.address.present?
      json.address do
        json.id bcba.address.id
        json.line1 bcba.address.line1
        json.line2 bcba.address.line2
        json.line3 bcba.address.line3
        json.zipcode bcba.address.zipcode
        json.city bcba.address.city
        json.state bcba.address.state
        json.country bcba.address.country
      end
    end
    if bcba.rbt_supervision.present?
      json.rbt_supervision do
        json.id bcba.rbt_supervision.id
        json.status bcba.rbt_supervision.status
      end
    end
  end
end
