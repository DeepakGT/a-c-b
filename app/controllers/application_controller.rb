class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    whitelisted_user_params = %i[first_name last_name address role_name]
    devise_parameter_sanitizer.permit(:sign_up, keys: whitelisted_user_params)
  end
end
