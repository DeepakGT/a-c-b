require 'sidekiq'
require 'sidekiq-cron'
class SyncWithCatalystWorker                      
  include Sidekiq::Worker
                                        
  def perform
    puts "#{DateTime.current}"
    puts "SyncWithCatalystJob is started"
    sync_data((Time.current.to_date-1).strftime('%m-%d-%Y'), (Time.current.to_date).strftime('%m-%d-%Y'))
    puts "SyncWithCatalystJob is completed"
    puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"        
  end

  private

  def sync_data(start_date, end_date)
    Loggers::Catalyst::SyncSoapNotesLoggerService.call(nil, "Syncing catalyst soap notes from #{start_date} to #{end_date} at #{Time.current} has started.")
    response_data_array = Catalyst::SyncDataOperation.call(start_date, end_date)
    Loggers::Catalyst::SyncSoapNotesLoggerService.call(nil, "Syncing catalyst soap notes from #{start_date} to #{end_date} at #{Time.current} is completed.")

    Loggers::Catalyst::SyncSoapNotesLoggerService.call(nil, "Rendering catalyst synced appointments from #{start_date} to #{end_date} at #{Time.current} has started.")
    result = Catalyst::RenderAppointmentsOperation.call
    Loggers::Catalyst::SyncSoapNotesLoggerService.call(nil, "Rendering catalyst synced appointments from #{start_date} to #{end_date} at #{Time.current} is completed.")
  end
  # end of private
end
