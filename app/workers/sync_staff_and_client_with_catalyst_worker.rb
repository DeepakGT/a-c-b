require 'sidekiq'
require 'sidekiq-cron'
class SyncStaffAndClientWithCatalystWorker
  include Sidekiq::Worker

  def perform
    puts "#{DateTime.now}"
    puts "SyncWithCatalystJob is started"
    sync_staff_and_client_data("01-01-1753")
    puts "SyncWithCatalystJob is completed"
    puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  end

  private

  def sync_staff_and_client_data(start_date)
    Catalyst::SyncClinicsOperation.call
    Catalyst::SyncStaffOperation.call(start_date)
    Catalyst::SyncClientsOperation.call(start_date)
  end
end
