namespace :update_scheduling_with_invalid_date do
    desc "Update start_time and end_time from invalid date to correct time from catalyst soap note"
    task update_start_time_and_end_time: :environment do
        Scheduling.where(start_time: "Invalid date", end_time: "Invalid date").each do |schedule|
            catalyst_data = CatalystData.find(schedule.catalyst_data_ids.first)
            schedule.end_time = catalyst_data.end_time
            schedule.start_time = catalyst_data.start_time
            schedule.units = catalyst_data.units
            schedule.save
        end
    end
end
  