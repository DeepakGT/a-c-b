require 'sidekiq'
require 'sidekiq-cron'

class RemoveDraftAppointmentsWorker                      
  include Sidekiq::Worker
                                        
  def perform
    puts "#{DateTime.current}"
    puts 'RemoveDraftAppointmentsWorker is started'
    remove_draft_appointments_worker
    puts 'RemoveDraftAppointmentsWorker is completed'
    puts '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'               
  end

  private

  def remove_draft_appointments_worker
    Scheduling.where(status: 'draft', date: ..Date.today + Constant.third.days).each do |scheduling_draft|
      scheduled_draft = Scheduling.find_by(id: scheduling_draft.id)
      scheduled_draft.delete
      sleep(0.5)
    end
  end
end
