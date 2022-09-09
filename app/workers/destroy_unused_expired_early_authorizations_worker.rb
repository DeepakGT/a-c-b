require 'sidekiq'
require 'sidekiq-cron'
class DestroyUnusedExpiredEarlyAuthorizationsWorker                       
  include Sidekiq::Worker
                                        
  def perform
    puts "#{DateTime.current}"
    puts "DestroyUnusedExpiredEarlyAuthorizationsJob is started"
    destroy_unused_expired_early_authorizations
    puts "DestroyUnusedExpiredEarlyAuthorizationsJob is completed"
    puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"               
  end

  private

  def destroy_unused_expired_early_authorizations
    expired_early_authorizations = ClientEnrollmentService.joins(:service).with_early_code_services.expired
    unused_expired_early_authorizations = expired_early_authorizations.with_zero_schedulings
    unused_expired_early_authorizations&.map{|authorization| authorization.destroy}
  end
  # end of private
end
