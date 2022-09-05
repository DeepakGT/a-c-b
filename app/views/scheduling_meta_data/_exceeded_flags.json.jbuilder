if past_schedules.exceeded_24_h_scheduling.any?
  json.exceeded_24_h true
else
  json.exceeded_24_h false
end
if past_schedules.exceeded_3_days_scheduling.any?
  json.exceeded_3_days true
else
  json.exceeded_3_days false
end
if past_schedules.exceeded_5_days_scheduling.any?
  json.exceeded_5_days true
else
  json.exceeded_5_days false
end
