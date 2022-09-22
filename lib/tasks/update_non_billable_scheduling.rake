namespace :update_non_billable_scheduling do
    desc "Update user address and phone numbers"
    task update_status: :environment do
        schedulings = Scheduling.where(status: "Non-Billable")
        schedulings.update_all(status: "Non_Billable")
    end
  end
  