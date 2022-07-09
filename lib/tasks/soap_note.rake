namespace :soap_note do
  desc "Fix add_date"
  task fix_add_date: :environment do
    SoapNote.all.each do |soap_note|
      if soap_note.add_date.present? 
        add_time = "#{soap_note.add_date.strftime('%Y-%m-%d')}"
        soap_note.add_time = DateTime.strptime(add_time, '%Y-%m-%d')
        soap_note.save(validate: false)
        if soap_note.add_time.zone=="EST"
          soap_note.add_time = soap_note.add_time + 5.hours
          soap_note.save(validate: false)
        else
          soap_note.add_time = soap_note.add_time + 4.hours
          soap_note.save(validate: false)
        end
      end
    end
  end
end
