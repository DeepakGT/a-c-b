require 'csv'
module SchedulingStatuses
  module CreateCsv
    class << self
      def call
        create_csv_of_status
      end

      private

      def create_csv_of_status
        CSV.open("lib/scheduling_data.csv", "wb") do |csv|
          csv << ['id', 'status']
          Scheduling.all.each do |schedule|
            csv << schedule.attributes.select{|key| key=='id' || key=='status'}.values
          end
        end
      end
    end
  end
end
