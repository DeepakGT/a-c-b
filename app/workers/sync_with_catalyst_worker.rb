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
    response_data_array = Catalyst::SyncDataOperation.call(start_date, end_date)
    result = Catalyst::RenderServiceOperation.call
  end
  # end of private
end
