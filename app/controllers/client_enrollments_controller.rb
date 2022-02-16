class ClientEnrollmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
  before_action :set_client
  before_action :set_client_enrollment, only: %i[show update destroy]

  def index
    @client_enrollments = @client.client_enrollments.order(is_primary: :desc).paginate(page: params[:page])
  end

  def create
    @client_enrollment = @client.client_enrollments.new(enrollment_params)
    @client_enrollment.is_primary = is_any_primary? ? true : false
    @client_enrollment.save
  end

  def show; end

  def update
    reset_primary if params[:is_primary].to_bool.true?
    @client_enrollment.update(enrollment_params)
  end

  def destroy
    @client_enrollment.destroy
  end

  private

  def authorize_user
    authorize ClientEnrollment if current_user.role_name!='super_admin'
  end

  def enrollment_params
    params.permit(:client_id, :funding_source_id, :is_primary, :insurance_id, :group, :group_employer, 
                  :subscriber_name, :subscriber_phone, :subscriber_dob, :provider_phone, 
                  :relationship, :source_of_payment, :enrollment_date, :terminated_on, :notes)
  end

  def set_client
    @client = Client.find(params[:client_id])
  end

  def set_client_enrollment
    @client_enrollment = @client.client_enrollments.find(params[:id])
  end

  def reset_primary
    client_enrollment = @client.client_enrollments.find_by(is_primary: true)
    client_enrollment.update(is_primary: false)
  end

  def is_any_primary?
    # return true if @client.client_enrollments.where(is_primary: true).blank?
    return false if @client.client_enrollments.find_by(is_primary: true).present?

    true
  end
  # end of private
  
end
