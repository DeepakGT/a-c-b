class SchedulingsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
  before_action :set_scheduling, only: :show

  def index
    @schedules = Scheduling.order(:date).paginate(page: params[:page])
  end

  def show; end

  def create
    @schedule = Scheduling.create(scheduling_params)
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
  # end of private
end
