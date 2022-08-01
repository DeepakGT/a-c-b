json.status 'success'
json.data do
  json.partial! 'catalyst_data_detail', catalyst_data: @catalyst_data
  json.appointments do
    json.array! @schedules do |schedule|
      json.partial! 'schedulings/scheduling_detail', schedule: schedule
      json.staff_role schedule.staff.role_name if schedule.staff.present?
      json.is_early_code service&.is_early_code
    end
  end
end
