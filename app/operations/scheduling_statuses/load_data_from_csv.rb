require 'csv'
module SchedulingStatuses
  module LoadDataFromCsv
    class << self
      def call
        load_data_from_csv
      end

      private

      def load_data_from_csv
        CSV.foreach(Rails.root.join("lib/scheduling_data.csv"), headers: true, header_converters: :symbol) do |schedule_data|
          schedule = Scheduling.find(schedule_data[:id]) rescue nil
          schedule&.status = schedule_data[:status]&.downcase
          schedule&.save(validate: false)
        end
      end
    end
  end
end
