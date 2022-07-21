require 'sidekiq'
require 'sidekiq-cron'
class SyncWithCatalystTwoMonthsWorker                      
  include Sidekiq::Worker
                                        
  def perform
    puts "#{DateTime.current}"
    puts "SyncWithCatalystJob is started"
    sync_data((Time.current.to_date-60).strftime('%m-%d-%Y'), (Time.current.to_date).strftime('%m-%d-%Y'))
    puts "SyncWithCatalystJob is completed"
    puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"        
  end

  private

  def sync_data(start_date, end_date)
    Loggers::Catalyst::SyncSoapNotesLoggerService.call(nil, "Syncing catalyst soap notes from #{start_date} to #{end_date} at #{Time.current} has started.")
    Catalyst::SyncSoapNotesInTwelveHoursChunkService.call(start_date, end_date)
    Loggers::Catalyst::SyncSoapNotesLoggerService.call(nil, "Syncing catalyst soap notes from #{start_date} to #{end_date} at #{Time.current} is completed.")

    RenderAppointments::MultipleSoapNotesOperation.call
    
    Loggers::Catalyst::SyncSoapNotesLoggerService.call(nil, "Rendering catalyst synced appointments from #{start_date} to #{end_date} at #{Time.current} has started.")
    Catalyst::RenderAppointmentsOperation.call
    Loggers::Catalyst::SyncSoapNotesLoggerService.call(nil, "Rendering catalyst synced appointments from #{start_date} to #{end_date} at #{Time.current} is completed.")
  
    # ClientEnrollmentService.all.each do |client_enrollment_service|
    #   ClientEnrollmentServices::UpdateUnitsColumnsOperation.call(client_enrollment_service)
    # end
  end
  # end of private
end
