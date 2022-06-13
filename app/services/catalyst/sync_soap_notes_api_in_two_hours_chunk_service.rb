module Catalyst
  module SyncSoapNotesInTwoHoursChunkService
    class << self
      def call(start_date, end_date)
        sync_soap_notes(start_date, end_date)
      end

      private

      def sync_soap_notes(start_date, end_date)
        start_time = "00:00"
        batch_date = start_date
        while batch_date < end_date
          end_time = "01:59"
          counter = 0
          while counter < 12
            Loggers::Catalyst::SyncSoapNotesLoggerService.call(nil, "Processing catalyst soap note sync of #{Time.current.strftime('%m-%d-%Y')} from #{start_time} to #{end_time}.")
            response_data_array = Catalyst::SyncDataOperation.call("#{batch_date} #{start_time}", "#{batch_date} #{end_time}")
            Loggers::Catalyst::SyncSoapNotesLoggerService.call(nil, "Processed catalyst soap note sync of #{Time.current.strftime('%m-%d-%Y')} from #{start_time} to #{end_time}.")
            start_time = (DateTime.strptime(start_time, "%H:%M") + 2.hours).strftime('%H:%M')
            end_time = (DateTime.strptime(end_time, "%H:%M") + 2.hours).strftime('%H:%M')
            counter += 1
          end
          batch_date = (DateTime.strptime(batch_date, '%m-%d-%Y') + 1.day).strftime('%m-%d-%Y')
        end
      end
    end
  end
end
