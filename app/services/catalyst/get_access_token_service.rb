require "uri"
require "net/http"

module Catalyst
  module GetAccessTokenService
    class << self
      def call
        get_catalyst_access_token
      end

      private

      def get_catalyst_access_token
        url = URI("https://api.datafinch.com/connect/token")
    
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = true
    
        request = Net::HTTP::Post.new(url)
        request["Authorization"] = "Basic aWhjX2FwaTowTTlFOWU4YzNl"
        form_data = [['grant_type', 'client_credentials']]
        request.set_form form_data, 'multipart/form-data'
        response = https.request(request)
        response_body = JSON.parse(response.body)
        response_body['access_token']
      end
    end
  end
end
