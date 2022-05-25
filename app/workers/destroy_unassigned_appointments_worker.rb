require 'sidekiq'
require 'sidekiq-cron'
class DestroyUnassignedAppointmentsWorker                       
  include Sidekiq::Worker
                                        
  def perform
    puts "#{DateTime.current}"
    puts "DestroyUnassignedAppointmentsJob is started"
    destroy_unassigned_appointments
    puts "DestroyUnassignedAppointmentsJob is completed"
    puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"               
  end

  private

  def destroy_unassigned_appointments
    unassigned_schedules = Scheduling.completed_scheduling.without_staff
    unassigned_schedules.destroy_all
  end
  # end of private
end
