require "uri"
require "net/http"

module Catalyst
  module SoapNotesApiService
    class << self
      def call(start_date, end_date, access_token)
        get_catalyst_data(start_date, end_date, access_token)
      end

      private

      def get_catalyst_data(start_date, end_date, access_token)
        url = URI("https://customerapi.datafinch.com/v1/SoapNote?StartTime=#{start_date}&EndTime=#{end_date}")
    
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = true
    
        request = Net::HTTP::Get.new(url)
        request["Authorization"] = "Bearer #{access_token}"
    
        response = https.request(request)
        response_body = JSON.parse(response.body)
      end
    end
  end
end
