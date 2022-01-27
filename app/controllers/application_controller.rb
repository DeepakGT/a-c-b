class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include Pundit
  before_action :configure_permitted_parameters, if: :devise_controller?
  rescue_from ActiveRecord::RecordNotFound, with: :send_record_not_found_response
  rescue_from Pundit::NotAuthorizedError, with: :not_authorized

  protected

  def configure_permitted_parameters
    whitelisted_user_params = ['first_name', 'last_name', 'role_id', 'clinic_id', 'supervisor_id', 'status', 'terminated_on',
                               'service_provider', {phone_numbers_attributes: %i[phone_type number], address_attributes: 
                                %i[line1 line2 line3 zipcode city state country], rbt_supervision_attributes: 
                                %i[status start_date end_date], services_attributes: 
                                %i[name status default_pay_code category display_pay_code tracking_id]}]
    # if self.service_provider?
    #   whitelisted_user_params << {rbt_supervisions: %i[status start_date end_date]}
    # end
    devise_parameter_sanitizer.permit(:sign_up, keys: whitelisted_user_params)
    devise_parameter_sanitizer.permit(:account_update, keys: whitelisted_user_params)
  end

  private

  def send_record_not_found_response
    render json: {status: :failure, errors: ['record not found']}, status: 404
  end

  def not_authorized
    render json: {status: :failure, errors: ['you are not authorized to perform this action.']}, status: 401
  end
  # end of private
end
