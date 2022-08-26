DATE_FORMAT = "%m-%d-%Y".freeze

class SyncClientSoapNotesJob < ApplicationJob
  queue_as :default

  def perform
    puts "#{DateTime.current}"
    puts "SyncClientSoapNotesJob is started"
    puts "Syncing Catalyst SOAP notes from 01 Feb 2022 to #{Date.current.to_date}"
    from = Date.strptime("07-01-2022", DATE_FORMAT).to_date
    to = Date.current.end_of_month
    while from < to
      begin
        puts "Syncing from #{from} - #{(from + 1.months).end_of_month}"
        sync_data(from.strftime(DATE_FORMAT), to.strftime(DATE_FORMAT))
      rescue
        puts "Error thrown for #{from} - #{(from + 1.months).end_of_month}"
        next
      ensure
        from = from + 2.months 
      end
    end
    puts "SyncClientSoapNotesJob is completed"
    puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  end

  def sync_data(start_date, end_date)
    Catalyst::SyncDataOperation.call(start_date, end_date)
    Catalyst::RenderAppointmentsOperation.call
  end
end
