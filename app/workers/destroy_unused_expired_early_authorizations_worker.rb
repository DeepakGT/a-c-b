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
    expired_early_authorizations = ClientEnrollmentService.joins(:service).where('services.is_early_code': true).expired
    unused_expired_early_authorizations = expired_early_authorizations.left_outer_joins(:schedulings).select('client_enrollment_services.*').group('id').having('count(schedulings.*) = ?', 0)
    unused_expired_early_authorizations.map{|authorization| authorization.destroy}
  end
  # end of private
end
