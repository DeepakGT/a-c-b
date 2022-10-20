json.id schedule.id
json.status I18n.t("activerecord.attributes.scheduling.statuses.#{schedule.status}").capitalize if schedule.status.present?
json.status_value schedule.status
json.date schedule.date
json.start_time schedule.start_time&.in_time_zone&.strftime("%I:%M %p")
json.end_time schedule.end_time&.in_time_zone&.strftime("%I:%M %p")
json.non_billable_reason schedule.non_billable_reason
