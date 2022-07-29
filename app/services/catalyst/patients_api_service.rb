require "uri"
require "net/http"

module Catalyst
  module PatientsApiService
    class << self
      def call(start_date, access_token)
        get_patient_data(start_date, access_token)
      end

      private

      def get_patient_data(start_date, access_token)
        url = URI("https://customerapi.datafinch.com/v1/Patient?StartTime=#{start_date}")
    
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = true
    
        request = Net::HTTP::Get.new(url)
        request["Authorization"] = "Bearer #{access_token}"
    
        response = https.request(request)
        JSON.parse(response.body)
      end
    end
  end
end
