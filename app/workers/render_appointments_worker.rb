require 'sidekiq'
require 'sidekiq-cron'
class RenderAppointmentsWorker                       
  include Sidekiq::Worker
                                        
  def perform
    puts "#{DateTime.current}"
    puts "RenderAppointmentsJob is started"
    Loggers::RenderAppointmentsLoggerService.call(nil, "Rendering appointments on #{DateTime.current.to_date} has started.")
    RenderAppointments::RenderAllSchedulesOperation.call
    Loggers::RenderAppointmentsLoggerService.call(nil, "Rendering appointments on #{DateTime.current.to_date} is completed.")
    puts "RenderAppointmentsJob is completed"
    puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"               
  end
end
