json.id schedule.id
json.status schedule.status
json.date schedule.date
json.start_time schedule.start_time&.in_time_zone&.strftime("%I:%M %p")
json.end_time schedule.end_time&.in_time_zone&.strftime("%I:%M %p")
json.non_billable_reason schedule.non_billable_reason
