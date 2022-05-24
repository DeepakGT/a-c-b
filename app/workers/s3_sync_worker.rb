require 'sidekiq'
require 'sidekiq-cron'
class S3SyncWorker                       
  include Sidekiq::Worker

  def perform
    puts "#{DateTime.current}"
    puts "S3SyncWorker is started"
    S3Sync::SyncAllTablesOperation.call
    puts "S3SyncWorker is completed"
    puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  end
end