class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    whitelisted_user_params = ['first_name', 'last_name', 'role_id', 'clinic_id', 'supervisor_id',
                                 'hired_at', 'web_address', 'status', 'terminated_at', 'pay_type',
                                 'service_provider', 'timing_type', 'hours_per_week', 'ot_exempt',
                                 'phone_ext', 'term_type', 'residency', 'status_date', 'driving_license',
                                 'driving_license_expires_at', 'date_of_birth', 'ssn', 'badge_id',
                                 'badge_type', {phone_numbers_attributes: %i[phone_type number], address_attributes: 
                                 %i[line1 line2 line3 zipcode city state country], rbt_supervision_attributes:
                                 %i[status start_date end_date], services_attributes: %i[name status default_pay_code
                                 category display_pay_code tracking_id]} ]
    # if self.service_provider?
    #   whitelisted_user_params << {rbt_supervisions: %i[status start_date end_date]}
    # end
    devise_parameter_sanitizer.permit(:sign_up, keys: whitelisted_user_params)
  end
end
