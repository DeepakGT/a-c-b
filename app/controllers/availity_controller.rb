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
    rows = CSV.parse(s3_data)
    rows.each_with_index do |row, index|
      row << (index == 0 ? Availity::ProcessClaimsOperation::AVAILITY_STATUS : "")
    end

    # initialize errors for reporting purpose and process claims
    missing_payerid_errors = []
    claim_status_errors = []
    Availity::ProcessClaimsOperation.process_claims(rows, missing_payerid_errors, claim_status_errors)

    if params[:testing] == "true"
      # save to csv file
      idx = params[:target_file].include?("/") ? params[:target_file].rindex("/") : -1
      CSV.open("#{Rails.root.join(Availity::ProcessClaimsOperation::AVAILITY_LOG_PATH)}/#{params[:target_file][idx + 1..]}", "wb") { |csv| rows.each { |row| csv << [row.first, row.second, row.last] } }
    else
      # upload data to S3
      updated_s3_data = CSV.generate { |csv| rows.each { |row| csv << row } }
      S3::S3ApiServices.put_file(s3_client, params[:bucket], params[:target_file], updated_s3_data)
    end

    if missing_payerid_errors.blank? && claim_status_errors.blank?
      render json: { success: true }
    else
      render json: { success: false, errors: { payerid_missing: missing_payerid_errors, claim_statuses: claim_status_errors } }
    end
  rescue => e
    render json: { success: false, errors: e.message }
  end

  private
  
  def authenticate
    authenticate_or_request_with_http_token do |token, options|
      ActiveSupport::SecurityUtils.secure_compare(token, TOKEN)
    end
  end
end
