class ClientEnrollmentServicesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
  before_action :set_client_enrollment_service, only: %i[show update destroy]

  def create
    set_client_enrollment
    @enrollment_service = @client_enrollment.client_enrollment_services.create(enrollment_service_params)
  end

  def show
    @enrollment_service  
  end

  def update
    ClientEnrollmentService.transaction do
      remove_service_providers if params[:service_providers_attributes].present?
      @enrollment_service.update(enrollment_service_params)
      update_client_enrollment if params[:funding_source_id].present?
    end
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
    if params[:funding_source_id].present?
      @client_enrollment = client.client_enrollments.find_by(funding_source_id: params[:funding_source_id])
    else
      @client_enrollment = client.client_enrollments.find_by(source_of_payment: 'self_pay')
    end
  end

  def set_client_enrollment_service
    @enrollment_service = ClientEnrollmentService.find(params[:id])
  end

  def update_client_enrollment
    set_client_enrollment 
    @enrollment_service.client_enrollment = @client_enrollment
    @enrollment_service.save
    RenderAppointments::RenderPartiallyRenderedSchedulesOperation.call(@enrollment_service.id) if @enrollment_service.client_enrollment&.funding_source&.name!='ABA Centers of America'
  end

  def enrollment_service_params
    params.permit(:service_id, :start_date, :end_date, :units, :minutes, :service_number,
                  service_providers_attributes: %i[id staff_id])
  end

  def remove_service_providers
    @enrollment_service.service_providers.destroy_all
  end
  # end of private
end
