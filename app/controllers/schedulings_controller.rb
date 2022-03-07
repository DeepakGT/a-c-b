class SchedulingsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
  before_action :set_scheduling, only: %i[show update destroy]

  def index
    schedules = Scheduling.all
    schedules = do_filter(schedules) if params[:search_value].present?
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

  def do_filter(schedules)
    if params[:search_by].present?
      case params[:search_by]
      when "client_name"
        fname, lname = params[:search_value].split(' ')
        schedules = schedules.joins(:client).by_first_name(fname) if fname.present?
        schedules = schedules.joins(:client).by_last_name(lname) if lname.present?
        return schedules
      when "staff_name"
        fname, lname = params[:search_value].split(' ')
        schedules = schedules.joins(:staff).by_first_name(fname) if fname.present?
        schedules = schedules.joins(:staff).by_last_name(lname) if lname.present?
        return schedules
      when "service"
        schedules.joins(:service).by_service(params[:search_value])
      else
        schedules
      end
    else
      search_on_all_fields(params[:search_value])
    end
  end

  def search_on_all_fields(query)
    schedules = Scheduling.joins(:staff, :client, :service).all
    fname, lname = query.split
    schedules = schedules.joins(:client).by_first_name(fname).by_last_name(lname)
         .or(schedules.by_first_name(fname).by_last_name(lname))
         .or(schedules.by_service(query))
  end
  # end of private
end
