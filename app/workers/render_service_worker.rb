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
    Scheduling.completed_scheduling.where(is_rendered: false).where(catalyst_data_ids: []).each do |schedule|
      if schedule.soap_notes.any?
        schedule.soap_notes.each do |soap_note|
          if soap_note.bcba_signature.to_bool.false?
            schedule.unrendered_reason.push('bcba_signature_absent')
            schedule.unrendered_reason = schedule.unrendered_reason.uniq
            schedule.save(validate: false)
          end
          if soap_note.clinical_director_signature.to_bool.false? 
            schedule.unrendered_reason.push('clinical_director_signature_absent')
            schedule.unrendered_reason = schedule.unrendered_reason.uniq
            schedule.save(validate: false)
          end
          if soap_note.rbt_signature.to_bool.false?  && schedule.staff.role_name=='rbt'
            schedule.unrendered_reason.push('rbt_signature_absent')
            schedule.unrendered_reason = schedule.unrendered_reason.uniq
            schedule.save(validate: false)
          end
          if !soap_note.signature_file.attached? && soap_note.caregiver_signature!=true
            schedule.unrendered_reason.push('caregiver_signature_absent')
            schedule.unrendered_reason = schedule.unrendered_reason.uniq
            schedule.save(validate: false)
          end
          if schedule.unrendered_reason.blank?
            schedule.is_rendered = true
            schedule.save(validate: false)
            break
          end
        end
      else
        schedule.unrendered_reason.push('soap_note_absent')
        schedule.unrendered_reason = schedule.unrendered_reason.uniq
        schedule.save(validate: false)
      end
    end
  end
  # end of private
end
