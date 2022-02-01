class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :configure_permitted_parameters, if: :devise_controller?
  rescue_from ActiveRecord::RecordNotFound, with: :send_record_not_found_response
  before_action :check_permissions, if: ->{ !devise_controller? && !current_user.super_admin? }

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

  def check_permissions
    not_authorized if current_user.role.permissions.blank? || !current_user.role.permissions.include?(params[:controller]+"_"+params[:action]) 
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
