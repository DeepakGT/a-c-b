require 'sidekiq'
require 'sidekiq-cron'
class RenderServiceWorker                       
  include Sidekiq::Worker
                                        
  def perform
    puts "#{DateTime.now}"
    puts "RenderServiceJob is started"
    render_service
    puts "RenderServiceJob is completed"
    puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"               
  end

  private

  def render_service
    Scheduling.completed_scheduling.where(is_rendered: false).each do |schedule|
      schedule.unrendered_reason = ''
      if schedule.soap_notes.any?
        schedule.soap_notes.each do |soap_note|
          if soap_note.bcba_signature==false 
            schedule.unrendered_reason += ' bcba_signature_absent'
            schedule.save(validate: false)
          end
          if soap_note.clinical_director_signature==false 
            schedule.unrendered_reason += ' clinical_director_signature_absent'
            schedule.save(validate: false)
          end
          if soap_note.rbt_signature==false 
            schedule.unrendered_reason += ' rbt_signature_absent'
            schedule.save(validate: false)
          end
          if !soap_note.signature_file.attached?
            schedule.unrendered_reason += ' caregiver_signature_absent'
            schedule.save(validate: false)
          end
          if schedule.unrendered_reason.blank?
            schedule.is_rendered = true
            schedule.unrendered_reason = ''
            schedule.save(validate: false)
            break
          end
        end
      else
        schedule.unrendered_reason = 'soap_note_absent'
        schedule.save(validate: false)
      end
    end
  end
  # end of private
end
