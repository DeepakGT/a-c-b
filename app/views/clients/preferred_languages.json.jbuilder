json.status 'success'
json.data do
  json.array! @preferred_languages do |preferred_language|
    json.id preferred_language.last
    json.type preferred_language.first
  end
end
