set :output, "log/cron.log"

every 1.day, at: '12:01 am' do
  rake "run_job:update_user_status"
end

# every 1.minute do
#   rake "run_job:update_user_status"
# end
