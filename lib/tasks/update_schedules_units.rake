namespace :update_schedules_units do
    desc "Update Schedule units and minutes for missed appointments"
    task update_units_and_minutes: :environment do
      schedules = Scheduling.where(units: nil, minutes: nil)
      schedules.each do |schedule|
        if schedule.start_time.present? && schedule.end_time.present?
            schedule.minutes = (schedule.end_time.to_time - schedule.start_time.to_time) / 1.minutes
            rem = schedule.minutes%15
            if rem == 0
                schedule.units = schedule.minutes/15
            elsif rem < 8
                schedule.units = (schedule.minutes - rem)/15
            else
                schedule.units = (schedule.minutes + 15 - rem)/15
            end
            schedule.save
        else
            schedule.units ||= 0
            schedule.minutes ||= 0
        end
      end
    end
  end
  