require 'net/http'
require 'uri'

module Availity
  module AvailityApiServices
    AVAILITY_CLAIM_STATUS_URL = "https://api.availity.com/availity/v1/claim-statuses".freeze

    class << self
      def get_access_token
        uri = URI.parse("https://api.availity.com/availity/v1/token")
        request = Net::HTTP::Post.new(uri)
        request.set_form_data(
          "client_id" => Rails.application.credentials.dig(:availity, :client_id),
          "client_secret" => Rails.application.credentials.dig(:availity, :client_secret),
          "grant_type" => "client_credentials",
          "scope" => "hipaa"
        )

        req_options = { use_ssl: uri.scheme == "https" }
        response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
          http.request(request)
        end

        response_body = JSON.parse(response.body)
        response_body['access_token']
      end

      def get_claim_data(access_token, url)
        uri = URI(url)
        https = Net::HTTP.new(uri.host, uri.port)
        https.use_ssl = uri.scheme == "https"
        request = Net::HTTP::Get.new(uri)
        request["Authorization"] = "Bearer #{access_token}"
        https.request(request)
      end

      def get_claim_statuses(access_token, parameters)
        url = "#{AVAILITY_CLAIM_STATUS_URL}?#{parameters}"
        get_claim_data(access_token, url)
      end

      def get_claim_statuses_by_id(access_token, id)
        url = "#{AVAILITY_CLAIM_STATUS_URL}/#{id}"
        get_claim_data(access_token, url)
      end
    end
  end
end


