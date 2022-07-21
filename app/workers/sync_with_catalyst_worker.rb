require 'sidekiq'
require 'sidekiq-cron'
class SyncWithCatalystWorker                      
  include Sidekiq::Worker
                                        
  def perform
    puts "#{DateTime.current}"
    puts "SyncWithCatalystJob is started"
    sync_data((Time.current-4.hours).strftime('%m-%d-%Y %H:%M'), (Time.current).strftime('%m-%d-%Y %H:%M'))
    puts "SyncWithCatalystJob is completed"
    puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"        
  end

  private

  def sync_data(start_time, end_time)
    Loggers::Catalyst::SyncSoapNotesLoggerService.call(nil, "Syncing catalyst soap notes from #{start_time} to #{end_time} has started.")
    Catalyst::SyncDataOperation.call(start_time, end_time)
    Loggers::Catalyst::SyncSoapNotesLoggerService.call(nil, "Syncing catalyst soap notes from #{start_time} to #{end_time} is completed.")

    RenderAppointments::MultipleSoapNotesOperation.call

    Loggers::Catalyst::SyncSoapNotesLoggerService.call(nil, "Rendering catalyst synced appointments from #{start_time} to #{end_time} has started.")
    Catalyst::RenderAppointmentsOperation.call
    Loggers::Catalyst::SyncSoapNotesLoggerService.call(nil, "Rendering catalyst synced appointments from #{start_time} to #{end_time} is completed.")
  
    # ClientEnrollmentService.all.each do |client_enrollment_service|
    #   ClientEnrollmentServices::UpdateUnitsColumnsOperation.call(client_enrollment_service)
    # end
  end
  # end of private
end
