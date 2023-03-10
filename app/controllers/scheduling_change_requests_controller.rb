class SchedulingChangeRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
  before_action :set_scheduling
  before_action :set_scheduling_change_request, only: :update

  def create
    @change_request = @schedule&.scheduling_change_requests&.create(change_request_params)
    if params[:status]&.to_s=='client_no_show' && @schedule&.scheduling_change_requests&.where(status: 'client_no_show').count<=1
      @schedule&.scheduling_change_requests&.by_approval_status&.update(approval_status: 'declined')
      change_approval_status('approved')
      @schedule&.user = current_user
      update_scheduling
    end
  end

  def update
    case params[:approval_status]&.to_s
    when 'approve'
      change_approval_status('approved')
      @schedule&.user = current_user
      update_scheduling
    when 'decline'
      change_approval_status('declined')
    else
      puts "#{params[:approval_status]}"
    end
  end

  private

  def authorize_user
    authorize SchedulingChangeRequest if current_user.role_name!='super_admin'
  end

  def set_scheduling
    @schedule = Scheduling.find(params[:scheduling_id]) rescue nil
  end

  def change_request_params
    params.permit(:date, :start_time, :end_time, :status)
  end

  def set_scheduling_change_request
    @change_request = SchedulingChangeRequest.find(params[:id]) rescue nil
  end

  def change_approval_status(approval_status)
    @change_request&.approval_status = approval_status
    @change_request&.save
  end

  def update_scheduling
    @schedule&.status = @change_request.status if @change_request&.status.present?
    @schedule&.start_time = @change_request.start_time if @change_request&.start_time.present?
    @schedule&.end_time = @change_request.end_time if @change_request&.end_time.present?
    @schedule&.date = @change_request.date if @change_request&.date.present?
    @schedule&.save
  end
end
