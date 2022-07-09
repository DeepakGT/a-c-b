require "uri"
require "net/http"

module Catalyst
  module ClinicsApiService
    class << self
      def call(access_token)
        get_clinics_data(access_token)
      end

      private

      def get_clinics_data(access_token)
        url = URI("https://customerapi.datafinch.com/v1/site")
    
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
