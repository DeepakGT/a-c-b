require 'sidekiq'
require 'sidekiq-cron'

class FirstNotificationDraftAppointmentWorker                      
  include Sidekiq::Worker
                                        
  def perform
    puts "#{DateTime.current}"
    puts 'first_notification_draft_appointment_worker is started'
    first_notification_draft_appointment_worker
    puts 'first_notification_draft_appointment_worker is completed'
    puts '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'               
  end

  private

  def first_notification_draft_appointment_worker
    Scheduling.where(status: 'draft', date: Date.today + 7.days).each do |scheduling_draft|
      scheduled_draft = Scheduling.find_by(id: scheduling_draft.id)
      sleep(0.5)
      scheduled_draft.notification_draft_appointment
    end
  end
end
