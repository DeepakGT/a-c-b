namespace :update_scheduling do
  desc "Update start_time and end_time"
  task update_start_time_and_end_time: :environment do
    Scheduling.where.not(start_time: nil, end_time: nil).each do |schedule|
      schedule.start_time = schedule.start_time.to_datetime.strftime('%H:%M').to_s
      schedule.end_time = schedule.end_time.to_datetime.strftime('%H:%M').to_s
      schedule.save
    end
  end
end
