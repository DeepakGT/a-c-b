if page_number.present?
  json.total_records list&.total_entries
  json.limit list&.per_page
  json.page page_number
end
