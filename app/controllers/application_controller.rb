class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include Pundit::Authorization
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_active_storage_host
  rescue_from ActiveRecord::RecordNotFound, with: :send_record_not_found_response
  rescue_from Pundit::NotAuthorizedError, with: :not_authorized

  protected

  def configure_permitted_parameters
    whitelisted_user_params = ['first_name', 'last_name', 'role_id', 'clinic_id', 'supervisor_id', 'status', 
                               'terminated_on', {phone_numbers_attributes: %i[id phone_type number], address_attributes: 
                                %i[line1 line2 line3 zipcode city state country], rbt_supervision_attributes: 
                                %i[status start_date end_date]}]
    devise_parameter_sanitizer.permit(:sign_up, keys: whitelisted_user_params)
    devise_parameter_sanitizer.permit(:account_update, keys: whitelisted_user_params)
  end

  private

  def set_active_storage_host
    ActiveStorage::Current.host = request.base_url
  end

  def send_record_not_found_response
    render json: {status: :failure, errors: [I18n.t('.controllers.generics.missing_record').capitalize]}, status: :bad_request
  end

  def not_authorized
    render json: {status: :failure, errors: [I18n.t('.controllers.generics.unauthorized').capitalize]}, status: :unauthorized
  end

  def unprosessable_entity_response(model)
    render json: { status: :failed, error: model.errors.full_messages }, status: :unprocessable_entity
  end
  
  def string_to_array(value)
    value = value.gsub(/\[|\]/, '').split(',')
  end

  def set_time_zone
    Time.zone = Rails.cache.read(current_user.id) if current_user
  end

  def incomplete_params
    render json: {status: :failure, errors: [I18n.t('.controllers.generics.incomplete_data').capitalize]}, status: :bad_request
  end
  # end of private  
end
