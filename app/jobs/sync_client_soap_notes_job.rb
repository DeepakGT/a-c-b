class SyncClientSoapNotesJob < ApplicationJob
  queue_as :default

  def perform
    puts "#{DateTime.current}"
    puts "SyncClientSoapNotesJob is started"
    puts "Syncing Catalyst SOAP notes from 01 Feb 2022 to #{Date.current.to_date}"
    from = Date.strptime("02-01-2022", "%m-%d-%Y").to_date
    to = Date.current.end_of_month
    while from < to
      begin
        puts "Syncing from #{from} - #{(from + 1.months).end_of_month}"
        sync_data(from.strftime('%m-%d-%Y'), to.strftime('%m-%d-%Y'))
        # sync_data((Time.current.to_date-60.days).strftime('%m-%d-%Y'), (Time.current.to_date).strftime('%m-%d-%Y'))
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
    response_data_array = Catalyst::SyncDataOperation.call(start_date, end_date)
    result = Catalyst::RenderAppointmentsOperation.call
    # ClientEnrollmentService.all.each do |client_enrollment_service|
    #   ClientEnrollmentServices::UpdateUnitsColumnsOperation.call(client_enrollment_service)
    # end
  end
end
