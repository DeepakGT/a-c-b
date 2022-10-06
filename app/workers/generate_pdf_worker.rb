require 'sidekiq'
require 'sidekiq-cron'
class GeneratePdfWorker                       
  include Sidekiq::Worker
  queue_as :GeneratePdf
                                        
  def perform(client_id, soap_notes_ids, user_id)
    puts "#{DateTime.current}"
    puts "GeneratePdfJob is started"

    # return from controller
    pdf_html = ActionController::Base.new.render_to_string(template: 'clients/soap_notes', layout: 'pdf', locals: {client_id: client_id, soap_notes_ids: soap_notes_ids})
    pdf = WickedPdf.new.pdf_from_string(pdf_html)

    SoapNotesPdfMailer.submission(user_id, pdf, client_id).deliver_now

    puts "GeneratePdfJob is completed"
    puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"   
  end
end
