class ClientEnrollmentServicesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client_enrollment, only: :create
  before_action :set_client_enrollment_service, only: :show

  def create
    @enrollment_service = @client_enrollment.client_enrollment_services.create(enrollment_service_params)
  end

  def show; end

  private

  def set_client_enrollment
    client = Client.find(params[:client_id])
    @client_enrollment = client.client_enrollments.find_by(funding_source_id: params[:funding_source_id])
  end

  def set_client_enrollment_service
    @enrollment_service = ClientEnrollmentService.find(params[:id])
  end

  def enrollment_service_params
    params.permit(:service_id, :start_date, :end_date, :units, :minutes, 
                  service_providers_attributes: %i[staff_id])
  end
  # end of private
end
