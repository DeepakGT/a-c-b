require 'sidekiq'
require 'sidekiq-cron'
class SyncWithCatalystOneMonthWorker                      
  include Sidekiq::Worker
                                        
  def perform
    puts "#{DateTime.now}"
    puts "SyncWithCatalystJob is started"
    sync_data((Time.now.to_date-30).strftime('%m-%d-%Y'), (Time.now.to_date).strftime('%m-%d-%Y'))
    puts "SyncWithCatalystJob is completed"
    puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"        
  end

  private

  def sync_data(start_date, end_date)
    response_data_array = Catalyst::SyncDataOperation.call(start_date, end_date)
    result = Catalyst::RenderServiceOperation.call
  end
  # end of private
end
