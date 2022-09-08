json.id funding_source.id
json.name funding_source.name
json.plan_name funding_source.plan_name
json.payor_type I18n.t("activerecord.attributes.funding_source.payor_types.#{funding_source.payor_type}")
json.network_status funding_source.network_status
json.status funding_source.status
json.email funding_source.email
json.notes funding_source.notes
json.clinic_id funding_source.clinic_id
if funding_source.address.present?
  json.address do
    json.id funding_source.address.id
    json.line1 funding_source.address.line1
    json.line2 funding_source.address.line2
    json.line3 funding_source.address.line3
    json.zipcode funding_source.address.zipcode
    json.city funding_source.address.city
    json.state funding_source.address.state
    json.country funding_source.address.country
  end
end
if funding_source.phone_number.present?
  json.phone_number do
    json.id funding_source.phone_number.id
    json.phone_type funding_source.phone_number.phone_type
    json.number funding_source.phone_number.number
  end
end
