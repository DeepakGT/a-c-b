require "uri"
require "net/http"

module Catalyst
  module UsersApiService
    class << self
      def call(start_date, access_token)
        get_users_data(start_date, access_token)
      end

      private

      def get_users_data(start_date, access_token)
        url = URI("https://customerapi.datafinch.com/v1/User?StartTime=#{start_date}")
    
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