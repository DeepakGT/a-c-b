class SchedulingsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
  before_action :set_scheduling, only: %i[show update destroy]

  def index
    schedules = do_filter
    @schedules = schedules.order(:date).paginate(page: params[:page])
  end

  def show; end

  def create
    @schedule = Scheduling.create(scheduling_params)
  end

  def update
    @schedule.update(scheduling_params)
  end

  def destroy
    @schedule.destroy
  end

  private

  def authorize_user
    authorize Scheduling if current_user.role_name!='super_admin'
  end

  def scheduling_params
    params.permit(:staff_id, :client_id, :service_id, :status, :date, :start_time, :end_time, :units, :minutes)
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
  # end of private
end
