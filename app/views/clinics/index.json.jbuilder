json.status 'success'
json.data do
  json.array! @clinics do |clinic|
    json.id clinic.id
    json.name clinic.name
  end
end
json.per_page @clinics.per_page
json.total_pages @clinics.total_pages
