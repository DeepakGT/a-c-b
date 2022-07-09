require 'sidekiq'
require 'sidekiq-cron'
class SyncStaffAndClientWithCatalystWorker
  include Sidekiq::Worker

  def perform
    puts "#{DateTime.current}"
    puts "SyncWithCatalystJob is started"
    sync_staff_and_client_data("01-01-1753")
    puts "SyncWithCatalystJob is completed"
    puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  end

  private

  def sync_staff_and_client_data(start_date)
    Loggers::Catalyst::SyncStaffAndClientsLoggerService.call(nil, "Clinic sync has started.")
    Catalyst::SyncClinicsOperation.call
    Loggers::Catalyst::SyncStaffAndClientsLoggerService.call(nil, "Clinic sync is completed.")
    Loggers::Catalyst::SyncStaffAndClientsLoggerService.call(nil, "Staff sync has started.")
    Catalyst::SyncStaffOperation.call(start_date)
    Loggers::Catalyst::SyncStaffAndClientsLoggerService.call(nil, "Staff sync is completed.")
    Loggers::Catalyst::SyncStaffAndClientsLoggerService.call(nil, "Client sync has started.")
    Catalyst::SyncClientsOperation.call(start_date)
    Loggers::Catalyst::SyncStaffAndClientsLoggerService.call(nil, "Client sync is completed.")
  end
end
