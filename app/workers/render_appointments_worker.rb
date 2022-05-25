require 'sidekiq'
require 'sidekiq-cron'
class RenderAppointmentsWorker                       
  include Sidekiq::Worker
                                        
  def perform
    puts "#{DateTime.current}"
    puts "RenderAppointmentsJob is started"
    RenderAppointments::RenderAllSchedulesOperation.call
    puts "RenderAppointmentsJob is completed"
    puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"               
  end
end
