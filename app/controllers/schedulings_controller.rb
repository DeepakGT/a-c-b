require 'will_paginate/array'
class SchedulingsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
  before_action :set_scheduling, only: %i[show update destroy update_without_client]
  before_action :set_client_enrollment_service, only: %i[create create_without_staff]

  def index
    @schedules = do_filter
  end

  def show; end

  def create
    @schedule = @client_enrollment_service.schedulings.new(scheduling_params)
    @schedule.creator_id = current_user.id
    @schedule.user = current_user
    @schedule.id = Scheduling.last.id + 1
    if is_create_request_via_catalyst_data
      update_data 
    else
      @schedule.save
    end
    update_units_columns(@schedule.client_enrollment_service)
  end

  def update
    @schedule.user = current_user
    return if !check_units
    update_status if params[:status].present?
    update_units_columns(@schedule.client_enrollment_service)
  end

  def destroy
    client_enrollment_service = @schedule.client_enrollment_services
    case current_user.role_name
    when 'super_admin'
      delete_scheduling
    when 'bcba', 'executive_director', 'client_care_coordinator', 'Clinical Director', 'administrator'
      delete_scheduling if @schedule.created_at.strftime('%Y-%m-%d')>=(Time.current-1.day).strftime('%Y-%m-%d')
    end
    update_units_columns(@schedule.client_enrollment_service)
  end

  def create_without_staff
    @schedule = @client_enrollment_service.schedulings.new(scheduling_params)
    @schedule.status = 'Non-Billable' if params[:status].blank?
    @schedule.creator_id = current_user.id
    @schedule.user = current_user
    @schedule.id = Scheduling.last.id + 1
    @schedule.save
  end

  def create_without_client
    @schedule = Scheduling.new(create_without_client_params)
    @schedule.status = 'Non-Billable'
    @schedule.creator_id = current_user.id
    @schedule.user = current_user
    @schedule.id = Scheduling.last.id + 1
    @schedule.save
  end

  def update_without_client
    @schedule.update(create_without_client_params)
  end

  private

  def authorize_user
    authorize Scheduling if current_user.role_name!='super_admin'
  end

  def scheduling_params
    arr = %i[ status date start_time end_time units minutes 
              client_enrollment_service_id cross_site_allowed service_address_id]

    arr.concat(%i[staff_id catalyst_soap_note_id]) if params[:action] == 'create'
    arr.concat(%i[staff_id]) if params[:action] == 'update'

    params.permit(arr)
  end

  def create_without_client_params
    params.permit(:staff_id, :date, :start_time, :end_time, :non_billable_reason)
  end

  def scheduling_params_when_bcba
    params.permit(%i[ status date start_time end_time units minutes])
  end

  def set_scheduling
    @schedule = Scheduling.find(params[:id])
  end

  def do_filter
    if params[:staff_ids].present? || params[:client_ids].present? || params[:service_ids].present? || current_user.role_name=='rbt' || current_user.role_name=='bcba' || params[:default_location_id].present?
      if !(params[:show_inactive].present? && (params[:show_inactive]==1 || params[:show_inactive]=="1"))
        schedules = Scheduling.left_outer_joins(staff: :staff_clinics, client_enrollment_service: [:service, {client_enrollment: :client}]).with_active_client
      else
        schedules = Scheduling.includes(staff: :staff_clinics, client_enrollment_service: [:service, {client_enrollment: :client}]).with_client
      end
    else
      schedules = Scheduling.with_client
      if !(params[:show_inactive].present? && (params[:show_inactive]==1 || params[:show_inactive]=="1"))
        schedules = schedules.joins(client_enrollment_service: {client_enrollment: :client}).with_active_client
      end
    end
    # schedules = schedules.and(Scheduling.by_staff_ids(current_user.id).without_client)
    schedules = schedules.by_staff_ids(string_to_array(params[:staff_ids])) if params[:staff_ids].present?
    schedules = schedules.by_client_ids(string_to_array(params[:client_ids])) if params[:client_ids].present?
    schedules = schedules.by_service_ids(string_to_array(params[:service_ids])) if params[:service_ids].present?

    schedules = schedules.on_date(params[:startDate]..params[:endDate]) if params[:startDate].present? && params[:endDate].present?

    if params[:default_location_id].present? && current_user.role_name!='rbt' && current_user.role_name!='bcba'
      location_id = params[:default_location_id]
      schedules = schedules.by_client_clinic(location_id).or(schedules.by_staff_home_clinic(location_id))
    end
    schedules = schedules.uniq.sort_by(&:date)
    schedules = schedules.paginate(page: params[:page]) if params[:page].present?
    schedules
  end

  def set_client_enrollment_service
    @client_enrollment_service = ClientEnrollmentService.find(params[:client_enrollment_service_id])
  end

  def update_client_enrollment_service
    @schedule.client_enrollment_service = ClientEnrollmentService.find(params[:client_enrollment_service_id])
    @schedule.save
  end

  # def is_renderable
  #   @schedule.reload
  #   if params[:status]=='Rendered' && @schedule.date<Time.current.to_date && @schedule.rendered_at.present?
  #     @schedule.errors.add(:status, message: "Scheduling could not be rendered.")
  #     return false 
  #   end
    
  #   true
  # end 

  def update_render_service
    RenderAppointments::RenderScheduleManualOperation.call(@schedule.id, params[:catalyst_soap_note_id]) if (params[:is_rendered].to_bool.true? || params[:status]=='Rendered') && @schedule.date<Time.current.to_date
  end

  def update_scheduling
    @schedule.update(scheduling_params)
    @schedule.updator_id = current_user.id
    update_render_service if params[:is_rendered].present? || params[:status]=='Rendered'
    update_client_enrollment_service if params[:client_enrollment_service_id].present?
    @schedule.save
  end

  def update_scheduling_when_bcba
    @schedule.update(scheduling_params_when_bcba)
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
    schedules = Scheduling.where('catalyst_data_ids @> ?', "{#{catalyst_data.id}}").where.not(id: @schedule.id)
    schedules.each do |schedule|
      schedule.catalyst_data_ids = schedule.catalyst_data_ids.uniq
      schedule.catalyst_data_ids.delete(catalyst_data.id) #if (schedule.catalyst_data_ids.present? && schedule.catalyst_data_ids.include?(catalyst_data.id))
      schedule.save(validate: false)
      RenderAppointments::RenderScheduleOperation.call(schedule.id) if !schedule.unrendered_reason.include?('units_does_not_match')
    end
    @schedule.start_time = catalyst_data.start_time
    @schedule.end_time = catalyst_data.end_time
    @schedule.units = catalyst_data.units if catalyst_data.units.present?
    @schedule.minutes = catalyst_data.minutes if catalyst_data.minutes.present?
    @schedule.date = catalyst_data.date
    @schedule.catalyst_data_ids.push(catalyst_data.id)
    @schedule.catalyst_data_ids.uniq!
    @schedule.id = Scheduling.last.id + 1
    if current_user.role_name=='super_admin' || current_user.role_name=='executive_director' || current_user.role_name=='client_care_coordinator' || current_user.role_name=='Clinical Director'
      @schedule.save(validate: false)
      create_or_update_soap_note(catalyst_data)
      catalyst_data.update(system_scheduling_id: @schedule.id)
      RenderAppointments::RenderScheduleOperation.call(@schedule.id)
    else
      @schedule.save
      if @schedule.save
        create_or_update_soap_note(catalyst_data)
        catalyst_data.update(system_scheduling_id: @schedule.id)
        RenderAppointments::RenderScheduleOperation.call(@schedule.id)
      end
    end
  end

  def create_or_update_soap_note(catalyst_data)
    soap_note = SoapNote.find_by(catalyst_data_id: catalyst_data.id)
    if soap_note.blank?
      soap_note = SoapNote.new(catalyst_data_id: catalyst_data.id)
      soap_note.add_date = catalyst_data.date
      soap_note.note = catalyst_data.note
      soap_note.creator_id = @schedule.staff_id
      soap_note.synced_with_catalyst = true
      soap_note.bcba_signature = true if catalyst_data.bcba_signature.present?
      soap_note.clinical_director_signature = true if catalyst_data.clinical_director_signature.present?
      soap_note.caregiver_signature = true if catalyst_data.caregiver_signature.present?
      if @schedule.staff&.role_name=='rbt' && catalyst_data.provider_signature.present?
        soap_note.rbt_signature = true
      elsif @schedule.staff&.role_name=='bcba' && catalyst_data.provider_signature.present?
        soap_note.bcba_signature = true
      end
      soap_note.save(validate: false)
    end
    soap_note.client_id = @schedule.client_enrollment_service.client_enrollment.client_id
    soap_note.scheduling_id = @schedule.id
    soap_note.save(validate: false)
  end
  
  def update_units_columns(client_enrollment_service)
    ClientEnrollmentServices::UpdateUnitsColumnsOperation.call(client_enrollment_service)
  end

  def delete_scheduling
    CatalystData.where(system_scheduling_id: @schedule.id).update_all(system_scheduling_id: nil)
    # catalyst_data = CatalystData.where('multiple_schedulings_ids @> ?', "{#{@schedule.id}}")
    # catalyst_data.each do |catalyst_datum| 
    #   catalyst_datum.multiple_schedulings_ids.delete("#{@schedule.id}")
    #   catalyst_datum.save
    # end
    @schedule.destroy
  end

  def check_units
    update_units_columns(@schedule.client_enrollment_service)
    if (params[:status]=='Scheduled' && @schedule.status!='Scheduled' && @schedule.status!='Rendered') && @schedule.client_enrollment_service.left_units<params[:units]
      @schedule.errors.add(:units, 'left in authorization are not enough to update this cancelled appointment to scheduled.')
      return false
    elsif params[:units].present? && params[:units]>@schedule.units && @schedule.client_enrollment_service.left_units<(params[:units]-@schedule.units)
      @schedule.errors.add(:units, 'left in authorization are not enough to update the units of appointment.')
      return false
    end
    true
  end

  def update_status
    if params[:status]=='Rendered'
      if current_user.role_name=='super_admin'
        update_scheduling 
        update_render_service
      else
        @schedule.errors.add(:schedule, 'You are not authorized to render appointment manually.')
        return false
      end
    elsif @schedule.status=='Rendered' && params[:status]!='Rendered'
      if current_user.role_name=='super_admin'
        update_scheduling 
        @schedule.is_rendered = false
        @schedule.rendered_at = nil
        @schedule.save
      else
        @schedule.errors.add(:schedule, 'You are not authorized to unrender appointment.')
        return false
      end
    else
      case current_user.role_name
      when 'administrator', 'executive_director', 'Clinical Director', 'client_care_coordinator', 'super_admin'
        update_scheduling 
      when 'bcba'
        update_scheduling_when_bcba
      end
    end
    true
  end
  # end of private
end
