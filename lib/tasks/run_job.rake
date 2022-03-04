namespace :run_job do
  desc "Update status of staff and client every midnight"
  task update_user_status: :environment do
    UpdateUserStatusJob.perform_later
  end
end
