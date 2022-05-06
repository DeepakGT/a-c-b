require 'will_paginate/array'
class SchedulingsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
  before_action :set_scheduling, only: %i[show update destroy]
  before_action :set_client_enrollment_service, only: :create

  def index
    schedules = Scheduling.all
    @schedules = do_filter(schedules)
  end

  def show; end

  def create
    @schedule = @client_enrollment_service.schedulings.new(scheduling_params)
    @schedule.creator_id = current_user.id
    @schedule.user = current_user
    if is_create_request_via_catalyst_data
      update_data 
    else
      @schedule.save
    end
  end

  def update
    @schedule.user = current_user
    if current_user.role_name=='super_admin' || current_user.role_name=='administrator' || current_user.role_name=='executive_director'
      update_render_service if params[:status]=='Rendered'
      return if !is_renderable
      update_scheduling 
    elsif current_user.role_name=='bcba' 
      if @schedule.date>=Time.current.to_date
        update_scheduling
      else
        update_render_service if params[:status]=='Rendered'
        return if !is_renderable
        @schedule.update(status: params[:status]) if params[:status].present?
      end
    end
  end

  def destroy
    CatalystData.where(system_scheduling_id: @schedule.id).update_all(system_scheduling_id: nil)
    catalyst_data =  CatalystData.where('multiple_schedulings_ids @> ?', "{#{@schedule.id}}")
    catalyst_data.each do |catalyst_datum| 
      catalyst_datum.multiple_schedulings_ids.delete("#{@schedule.id}")
      catalyst_datum.save
    end
    @schedule.destroy
  end

  private

  def authorize_user
    authorize Scheduling if current_user.role_name!='super_admin'
  end

  def scheduling_params
    params.permit(:staff_id, :status, :date, :start_time, :end_time, :units, :minutes, 
                  :client_enrollment_service_id, :cross_site_allowed, :service_address_id)
  end

  def set_scheduling
    @schedule = Scheduling.find(params[:id])
  end

  def do_filter(schedules)
    schedules = schedules.by_staff_ids(string_to_array(params[:staff_ids])) if params[:staff_ids].present?
    schedules = schedules.by_client_ids(string_to_array(params[:client_ids])) if params[:client_ids].present?
    schedules = schedules.by_service_ids(string_to_array(params[:service_ids])) if params[:service_ids].present?
    if params[:default_location_id].present?
      location_id = params[:default_location_id]
      schedules = schedules.left_outer_joins(client_enrollment_service: {client_enrollment: :client}).by_client_clinic(location_id)
                           .or(schedules.by_staff_clinic(location_id)).left_outer_joins(staff: :staff_clinics)
    end

    if params[:staff_ids].blank? && params[:client_ids].blank? && params[:service_ids].blank?
      if current_user.role_name=='bcba'
        schedules = schedules.joins(client_enrollment_service: {client_enrollment: :client}).where('clients.bcba_id': current_user.id).or(schedules.where(staff_id: current_user.id))
      # elsif current_user.role_name=='rbt'
      #   schedules = schedules.where(staff_id: current_user.id)
      end
    end
    if params[:startDate].present? && params[:endDate].present?
      schedules = schedules.on_date(params[:startDate]..params[:endDate])
    end
    schedules = schedules.uniq.sort_by(&:date)
    if params[:page].present?
      schedules = schedules.paginate(page: params[:page])
    end
    schedules
  end

  def set_client_enrollment_service
    @client_enrollment_service = ClientEnrollmentService.find(params[:client_enrollment_service_id])
  end

  def update_client_enrollment_service
    @schedule.client_enrollment_service = ClientEnrollmentService.find(params[:client_enrollment_service_id])
    @schedule.save
  end

  def is_renderable
    if params[:status]=='Rendered' && @schedule.date<Time.current.to_date && @schedule.is_rendered==false
      @schedule.errors.add(:status, message: "Scheduling could not be rendered.")
      return false 
    end
    
    true
  end 

  def update_render_service
    if params[:is_rendered].to_bool.true? || params[:status]=='Rendered'
      if @schedule.date<Time.current.to_date
        RenderAppointments::RenderScheduleOperation.call(@schedule.id)
      end
    end
  end

  def update_scheduling
    @schedule.update(scheduling_params)
    @schedule.updator_id = current_user.id
    update_render_service if params[:is_rendered].present? || params[:status]=='Rendered'
    update_client_enrollment_service if params[:client_enrollment_service_id].present?
    @schedule.save
  end

  def is_create_request_via_catalyst_data
    return true if params[:catalyst_data_id].present?

    false
  end

  def update_data
    catalyst_data = CatalystData.find(params[:catalyst_data_id])
    @schedule.start_time = catalyst_data.start_time
    @schedule.end_time = catalyst_data.end_time
    @schedule.units = catalyst_data.units if catalyst_data.units.present?
    @schedule.minutes = catalyst_data.minutes if catalyst_data.minutes.present?
    @schedule.date = catalyst_data.date
    @schedule.catalyst_data_ids.push(catalyst_data.id)
    @schedule.save(validate: false)
    catalyst_data.update(system_scheduling_id: @schedule.id, is_appointment_found: true, multiple_schedulings_ids: [])
  end
  # end of private
end
