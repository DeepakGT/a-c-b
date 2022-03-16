class SchedulingsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
  before_action :set_scheduling, only: %i[show update destroy]
  before_action :set_client_enrollment_service, only: :create

  def index
    schedules = do_filter
    @schedules = schedules.order(:date).paginate(page: params[:page])
  end

  def show; end

  def create
    @schedule = @client_enrollment_service.schedulings.create(scheduling_params)
  end

  def update
    @schedule.update(scheduling_params)
    update_client_enrollment_service if params[:client_enrollment_service_id].present?
  end

  def destroy
    @schedule.destroy
  end

  private

  def authorize_user
    authorize Scheduling if current_user.role_name!='super_admin'
  end

  def scheduling_params
    params.permit(:staff_id, :status, :date, :start_time, :end_time, :units, :minutes, :client_enrollment_service_id)
  end

  def set_scheduling
    @schedule = Scheduling.find(params[:id])
  end

  def do_filter
    schedules = Scheduling.all
    schedules = schedules.by_staff_ids(string_to_array(params[:staff_ids])) if params[:staff_ids].present?
    schedules = schedules.by_client_ids(string_to_array(params[:client_ids])) if params[:client_ids].present?
    schedules = schedules.by_service_ids(string_to_array(params[:service_ids])) if params[:service_ids].present?
    schedules
  end

  def set_client_enrollment_service
    @client_enrollment_service = ClientEnrollmentService.find(params[:client_enrollment_service_id])
  end

  def update_client_enrollment_service
    @schedule.client_enrollment_service = ClientEnrollmentService.find(params[:client_enrollment_service_id])
    @schedule.save
  end
  # end of private
end
