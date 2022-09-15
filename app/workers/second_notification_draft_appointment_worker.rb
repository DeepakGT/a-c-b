require 'sidekiq'
require 'sidekiq-cron'

class SecondNotificationDraftAppointmentWorker                      
  include Sidekiq::Worker
                                        
  def perform
    puts "#{DateTime.current}"
    puts "second_notification_draft_appointment_worker is started"
    second_notification_draft_appointment_worker
    puts "second_notification_draft_appointment_worker is completed"
    puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"               
  end

  private

  def second_notification_draft_appointment_worker
    Scheduling.where(status: 'draft', date: Date.today + 5.days).each do |scheduling_draft|
      scheduled_draft = Scheduling.find_by(id: scheduling_draft.id)
      scheduled_draft.notification_draft_appointment
      sleep(0.5)
    end
  end
end
