require 'sidekiq'
require 'sidekiq-cron'
class RenderServiceWorker                       
  include Sidekiq::Worker
                                        
  def perform
    puts "#{DateTime.now}"
    puts "RenderServiceJob is started"
    RenderService::RenderAllSchedules.call
    puts "RenderServiceJob is completed"
    puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"               
  end
  # end of private
end
