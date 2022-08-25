class AvailityController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods

  TOKEN = Rails.application.credentials[:connect_access_token]

  before_action :authenticate

  def update_claim_statuses
    response.headers['Access-Control-Allow-Origin'] = '*'
    Availity::ProcessClaimsOperation.process_s3_claims(params[:bucket], params[:source_file], params[:target_file], "availity_field_mapping", "availity_payer_mapping", "availity_provider_mapping", params[:testing] == "true")
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
