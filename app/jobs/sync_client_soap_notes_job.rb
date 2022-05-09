class SyncClientSoapNotesJob < ApplicationJob
  queue_as :default

  def perform
    puts "#{DateTime.current}"
    puts "SyncClientSoapNotesJob is started"
    sync_data((Time.current.to_date-60).strftime('%m-%d-%Y'), (Time.current.to_date).strftime('%m-%d-%Y'))
    puts "SyncClientSoapNotesJob is completed"
    puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  end

  def sync_data(start_date, end_date)
    response_data_array = Catalyst::SyncDataOperation.call(start_date, end_date)
    result = Catalyst::RenderAppointmentsOperation.call
  end
end
