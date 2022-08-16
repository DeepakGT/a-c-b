require 'csv'

class AvailityController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods

  TOKEN = Rails.application.credentials[:connect_access_token]

  before_action :authenticate

  def update_claim_statuses
    response.headers['Access-Control-Allow-Origin'] = '*'

    # get data from S3
    s3_client = S3::S3ApiServices.get_s3_client
    s3_data = S3::S3ApiServices.get_file(s3_client, params[:bucket], params[:source_file])

    # parse S3 data
    rows = CSV.parse(s3_data, headers: true)
    rows.each do |row|
      row[Availity::ProcessClaimsOperation::AVAILITY_STATUS] = ""
    end

    # process claims
    Availity::ProcessClaimsOperation.process_claims(rows, "availity_field_mapping", "availity_payer_mapping")

    if params[:testing] == "true"
      # save to csv file
      # for privacy, only save some columns
      CSV.open("#{Rails.root.join(Availity::ProcessClaimsOperation::AVAILITY_LOG_PATH)}/test.csv", "wb") do |csv|
        csv << [Availity::ProcessClaimsOperation::CLAIM_NUMBER, Availity::ProcessClaimsOperation::PAYORID, Availity::ProcessClaimsOperation::AVAILITY_STATUS]
        rows.each { |row| csv << [row[Availity::ProcessClaimsOperation::CLAIM_NUMBER], row[Availity::ProcessClaimsOperation::PAYORID], row[Availity::ProcessClaimsOperation::AVAILITY_STATUS]] }
      end
    else
      # upload data to S3
      updated_s3_data = CSV.generate(headers: true) do |csv|
        csv << rows.headers
        rows.each { |row| csv << row }
      end
      S3::S3ApiServices.put_file(s3_client, params[:bucket], params[:target_file], updated_s3_data)
    end

    render json: { success: true }, status: 200
  rescue => e
    render json: { success: false, error: e.message }, status: 500
  end

  private
  
  def authenticate
    authenticate_or_request_with_http_token do |token, options|
      ActiveSupport::SecurityUtils.secure_compare(token, TOKEN)
    end
  end
end
