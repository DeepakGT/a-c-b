require 'sidekiq'
require 'sidekiq-cron'
class SyncWithCatalystWorker                      
  include Sidekiq::Worker
                                        
  def perform
    puts "#{DateTime.current}"
    puts "SyncWithCatalystJob is started"
    sync_data((Time.current.to_date-3).strftime('%m-%d-%Y'), (Time.current.to_date).strftime('%m-%d-%Y'))
    puts "SyncWithCatalystJob is completed"
    puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"        
  end

  private

  def sync_data(start_date, end_date)
    Loggers::Catalyst::SyncSoapNotesLoggerService.call(nil, "Syncing catalyst soap notes from #{start_date} to #{end_date} at #{Time.current} has started.")

    batch_start_date = start_date
    while batch_start_date < end_date
      batch_end_date = (DateTime.strptime(batch_start_date, '%m-%d-%Y')+1.days).strftime('%m-%d-%Y')
      Loggers::Catalyst::SyncSoapNotesLoggerService.call(nil, "From #{batch_start_date} to #{batch_end_date}, processing catalyst soap note sync at #{Time.current}.")
      response_data_array = Catalyst::SyncDataOperation.call(batch_start_date, batch_end_date)
      Loggers::Catalyst::SyncSoapNotesLoggerService.call(nil, "From #{batch_start_date} to #{batch_end_date}, processed catalyst soap note sync at #{Time.current}.")
      batch_start_date = batch_end_date
    end

    Loggers::Catalyst::SyncSoapNotesLoggerService.call(nil, "Syncing catalyst soap notes from #{start_date} to #{end_date} at #{Time.current} is completed.")

    Loggers::Catalyst::SyncSoapNotesLoggerService.call(nil, "Rendering catalyst synced appointments from #{start_date} to #{end_date} at #{Time.current} has started.")
    result = Catalyst::RenderAppointmentsOperation.call
    Loggers::Catalyst::SyncSoapNotesLoggerService.call(nil, "Rendering catalyst synced appointments from #{start_date} to #{end_date} at #{Time.current} is completed.")
  end
  # end of private
end
