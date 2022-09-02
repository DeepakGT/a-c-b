require 'net/http'
require 'uri'

module Availity
  module AvailityApiServices
    AVAILITY_CLAIM_STATUS_URL = "https://api.availity.com/availity/v1/claim-statuses".freeze
    AVAILITY_ACTIVE_PAYERS_URL = "https://api.availity.com/availity/v1/configurations?type=claim-statuses-inquiry".freeze

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

      def get_active_payers(access_token)
        active_payers = {}
        offset = 0
        limit = 50

        # send requests to Availity to get the list of active payers that support 276 claim-status transaction type
        # Availity will not include all of the payers in a single request
        # instead it breaks up the results into multiple pages where each page needs a separate request
        loop do
          url = "#{AVAILITY_ACTIVE_PAYERS_URL}&offset=#{offset}&limit=#{limit}"
          response = get_claim_data(access_token, url)
          resp_data = JSON.parse(response.body)
          offset = resp_data["count"] + resp_data["offset"]
          limit = resp_data["limit"]

          resp_data["configurations"].each do |config|
            active_payers[config["payerId"]] = true unless active_payers.key?(config["payerId"])
          end

          break if offset >= resp_data["totalCount"]
        end

        active_payers
      end
    end
  end
end


