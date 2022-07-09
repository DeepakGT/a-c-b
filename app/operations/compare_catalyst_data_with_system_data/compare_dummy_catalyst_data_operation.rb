module CompareCatalystDataWithSystemData
  module CompareDummyCatalystDataOperation
    class << self
      def call
        response_data_array = compare_dummy_catalyst_data
      end

      private

      def compare_dummy_catalyst_data
        response_data_array = []
        CatalystData.all.each do |catalyst_data|
          response_data_hash = CompareCatalystDataWithSystemData::CompareSyncedDataOperation.call(catalyst_data)
          response_data_array.push(response_data_hash) if response_data_hash.any?
        end
        response_data_array
      end
    end
  end
end
