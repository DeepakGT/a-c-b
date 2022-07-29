namespace :update_schedules_units do
    desc "Update Schedule units and minutes for missed appointments"
    task update_units_and_minutes: :environment do
      schedules = Scheduling.where(units: nil, minutes: nil)
      schedules.each do |schedule|
        if schedule.start_time.present? && schedule.end_time.present?
            schedule.minutes = (schedule.end_time.to_time - schedule.start_time.to_time) / 1.minutes
            schedule.units = schedule.calculate_units(schedule.minutes)
        else
            schedule.units ||= 0
            schedule.minutes ||= 0
        end
      end
    end
  end
  