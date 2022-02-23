class SchedulingsController < ApplicationController
  before_action :authenticate_user!

  def index
    @schedules = Scheduling.order(:date).paginate(page: params[:page])
  end

  def create
    @schedule = Scheduling.create(scheduling_params)
  end

  private

  def scheduling_params
    params.permit(:staff_id, :client_id, :service_id, :status, :date, :start_time, :end_time, :units, :minutes)
  end
  # end of private
end
