json.status 'success'
json.data do
  json.array! @unassigned_notes do |unassigned_note|
    json.partial! 'catalyst/catalyst_data_detail', catalyst_data: unassigned_note
  end
end
