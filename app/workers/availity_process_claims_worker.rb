require 'sidekiq'
require 'sidekiq-cron'
class AvailityProcessClaimsWorker
  include Sidekiq::Worker

  def perform
    puts "*** #{DateTime.current} - AvailityProcessClaimsWorker started..."
    bucket = Rails.application.credentials.dig(:aws, :bucket_for_availity)
    source_file = ApplicationConfig.find_by(config_key: "availity_status_s3_source").config_value rescue ""
    target_file = ApplicationConfig.find_by(config_key: "availity_status_s3_target").config_value rescue ""
    Availity::ProcessClaimsOperation.process_s3_claims(bucket, source_file, target_file, "availity_field_mapping", "availity_payer_mapping", "availity_provider_mapping", false)
    puts "*** #{DateTime.current} - AvailityProcessClaimsWorker finished!"
  rescue => e
    puts "*** ERROR: #{e.message} => #{e.backtrace}"
  end
end
