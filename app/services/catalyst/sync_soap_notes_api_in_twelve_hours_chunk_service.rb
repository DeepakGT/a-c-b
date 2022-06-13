module Catalyst
  module SyncSoapNotesInTwelveHoursChunkService
    class << self
      def call(start_date, end_date)
        sync_soap_notes(start_date, end_date)
      end

      private

      def sync_soap_notes(start_date, end_date)
        batch_date = start_date
        while batch_date < end_date
          start_time = "00:00"
          end_time = "11:59"
          Loggers::Catalyst::SyncSoapNotesLoggerService.call(nil, "Processing catalyst soap note sync of #{batch_date} from #{start_time} to #{end_time}.")
          response_data_array = Catalyst::SyncDataOperation.call("#{batch_date} #{start_time}", "#{batch_date} #{end_time}")
          Loggers::Catalyst::SyncSoapNotesLoggerService.call(nil, "Processed catalyst soap note sync of #{batch_date} from #{start_time} to #{end_time}.")

          start_time = "12:00"
          end_time = "23:59"
          Loggers::Catalyst::SyncSoapNotesLoggerService.call(nil, "Processing catalyst soap note sync of #{batch_date} from #{start_time} to #{end_time}.")
          response_data_array = Catalyst::SyncDataOperation.call("#{batch_date} #{start_time}", "#{batch_date} #{end_time}")
          Loggers::Catalyst::SyncSoapNotesLoggerService.call(nil, "Processed catalyst soap note sync of #{batch_date} from #{start_time} to #{end_time}.")
          
          batch_date = (DateTime.strptime(batch_date, '%m-%d-%Y') + 1.day).strftime('%m-%d-%Y')
        end
      end
    end
  end
end
