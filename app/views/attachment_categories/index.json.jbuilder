json.status "success"
json.data do
  json.array! @attachment_categories do |attachment_category|
    json.id attachment_category.id
    json.name attachment_category.name.capitalize
  end
end
