class ClientEnrollmentServicesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
  before_action :set_client_enrollment_service, only: %i[show update destroy]

  def create
    set_client_enrollment
    @enrollment_service = @client_enrollment.client_enrollment_services.create(enrollment_service_params)
  end

  def show; end

  def update 
    @enrollment_service.update(enrollment_service_params)
    update_client_enrollment if params[:funding_source_id].present?
  end

  def destroy
    @enrollment_service.destroy
  end

  private

  def authorize_user
    authorize ClientEnrollmentService if current_user.role_name != 'super_admin'
  end

  def set_client_enrollment
    client = Client.find(params[:client_id])
    @client_enrollment = client.client_enrollments.find_by(funding_source_id: params[:funding_source_id])
  end

  def set_client_enrollment_service
    @enrollment_service = ClientEnrollmentService.find(params[:id])
  end

  def update_client_enrollment
    set_client_enrollment 
    @enrollment_service.client_enrollment = @client_enrollment
    @enrollment_service.save
  end

  def enrollment_service_params
    params.permit(:service_id, :start_date, :end_date, :units, :minutes, :service_number,
                  service_providers_attributes: %i[id staff_id])
  end
  # end of private
end
