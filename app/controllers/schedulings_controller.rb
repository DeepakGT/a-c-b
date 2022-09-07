require 'will_paginate/array'

class SchedulingsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user, except: %i[render_appointment split_appointment_detail create_split_appointment]
  before_action :set_scheduling, only: %i[show update destroy update_without_client]
  before_action :set_client_enrollment_service, only: %i[create create_without_staff]
  before_action :set_db_time_format, only: %i[create update create_without_staff create_split_appointment create_without_client update_without_client]

  def index
    @schedules = do_filter
  end

  def show
    @schedule
  end

  def create
    @schedule = @client_enrollment_service&.schedulings&.new(scheduling_params)
    @schedule&.creator_id = current_user.id
    if is_create_request_via_catalyst_data
      update_data 
    else
      @schedule&.save
    end
    update_staff_legacy_number
  end

  def range_recurrences
    ranges = Scheduling.range_recurrences(params[:range_recurrences], scheduling_params, current_user)
    if ranges[:status] == 'success'
      render json: ranges, status: :ok
    else
      render json: ranges, status: :bad_request
    end
  end

  def pattern_recurrences
    pattern = Scheduling.pattern_recurrences(params[:recurrcer_pattern], scheduling_params, current_user)
    if pattern[:status] == 'success'
      render json: pattern, status: :ok
    else
      render json: pattern, status: :bad_request
    end
  end

  def create_split_appointment
    ids = []
    schedule_hash = build_schedule_hash
    parent_schedule = Scheduling.find(params[:schedule_id]) rescue nil
    params[:split_schedules].each do |schedule|
      schedule_details_hash = build_schedule_details_hash(schedule)
      schedule_params = schedule_hash.merge!(schedule_details_hash.merge(appointment_office_id: parent_schedule.appointment_office_id))
      @schedule = Scheduling.new(schedule_params)
      @schedule&.save(validate: false)
      update_catalyst_data_and_soap_notes_for_split_appointment(schedule)
      ids.push @schedule&.id
      audit = @schedule&.audits&.new(action: 'split_appointment', user_id: current_user.id, user_type: 'User',username: "#{current_user.first_name} #{current_user.last_name}", audited_changes: {})
      audit.audited_changes["start_time"] = ["#{parent_schedule&.start_time}", "#{@schedule&.start_time}"] if parent_schedule&.start_time!=@schedule&.start_time
      audit&.audited_changes["end_time"] = ["#{parent_schedule&.end_time}", "#{@schedule&.end_time}"] if parent_schedule&.end_time!=@schedule&.end_time
      audit&.audited_changes["units"] = [parent_schedule&.units, @schedule&.units] if parent_schedule&.units!=@schedule&.units
      audit&.save
    end
    delete_old_schedule(params[:schedule_id])
    @schedules = Scheduling.where(id: ids)
  end

  def update
    @schedule&.user = current_user
    return if !check_units
    
    update_status if params[:status].present?
    update_staff_legacy_number
  end

  def destroy
    case current_user.role_name
    when 'super_admin'
      delete_scheduling
    when 'bcba', 'executive_director', 'client_care_coordinator', 'Clinical Director', 'administrator'
      delete_scheduling if @schedule&.created_at&.strftime('%Y-%m-%d')>=(Time.current-1.day).strftime('%Y-%m-%d')
    else
      puts "Cannot deleted by user role #{current_user.role}"
    end
  end

  def create_without_staff
    @schedule = @client_enrollment_service.schedulings.new(scheduling_params)
    @schedule.status = 'non_billable' if params[:status].blank?
    @schedule.creator_id = current_user.id
    @schedule.save
  end

  def render_appointment
    @schedule = Scheduling.find(params[:scheduling_id]) rescue nil
    manual_rendering
  end
  
  def create_without_client
    @schedule = Scheduling.new(create_without_client_params)
    @schedule.status = 'non_billable'
    @schedule.creator_id = current_user.id
    @schedule.save
  end

  def update_without_client
    @schedule.update(create_without_client_params)
    @schedule.save
  end

  def split_appointment_detail
    @schedule = Scheduling.find(params[:id]) rescue nil
  end

  private

  def authorize_user
    authorize Scheduling if current_user.role_name!='super_admin'
  end

  def scheduling_params
    params.permit(
      :status, :date, :start_time, :end_time, :units, :minutes, :staff_id,
      :client_enrollment_service_id, :cross_site_allowed, :service_address_id, :catalyst_soap_note_id,
      range_recurrences: %I[start end], recurrcer_pattern: [:recurrence, :quantity, {days: []}]
    )
  end

  def build_schedule_hash
    {
      date: params[:date],
      client_enrollment_service_id: params[:client_enrollment_service_id],
      creator_id: current_user.id,
      staff_id: params[:staff_id],
      user: current_user
    }
  end

  def build_schedule_details_hash(schedule)
    {
      start_time: schedule[:start_time],
      end_time: schedule[:end_time],
      units: schedule[:units],
      service_address_id: schedule[:service_address_id],
      catalyst_data_ids: schedule[:catalyst_data_id]&.to_s&.split(' ')
    }
  end

  def update_catalyst_data_and_soap_notes_for_split_appointment(schedule)
    catalyst_data = CatalystData.find(schedule[:catalyst_data_id]) rescue nil
    catalyst_data&.update(system_scheduling_id: @schedule&.id)
    create_or_update_soap_note(catalyst_data)
  end

  def delete_old_schedule(schedule_id)
    CatalystData.where(system_scheduling_id: schedule_id)&.update_all(system_scheduling_id: nil)
    Scheduling.find_by(id: schedule_id)&.destroy
  end

  def create_without_client_params
    params.permit(:staff_id, :date, :start_time, :end_time, :non_billable_reason, :appointment_office_id)
  end

  def scheduling_params_when_bcba
    params.permit(%i[status date start_time end_time units minutes])
  end

  def set_scheduling
    @schedule = Scheduling.find(params[:id]) rescue nil
  end

  def do_filter
    schedules = filter_schedules
    schedules = schedules.or(Scheduling.by_staff_ids(current_user.id).without_client)
    schedules = schedules.by_staff_ids(string_to_array(params[:staff_ids])) if params[:staff_ids].present?
    schedules = schedules.by_client_ids(string_to_array(params[:client_ids])) if params[:client_ids].present?
    schedules = schedules.by_service_ids(string_to_array(params[:service_ids])) if params[:service_ids].present?

    schedules = schedules.on_date(params[:startDate]..params[:endDate]) if params[:startDate].present? && params[:endDate].present?

    if params[:default_location_id].present? && current_user.role_name!='rbt' && current_user.role_name!='bcba'
      location_id = params[:default_location_id]
      schedules = schedules.by_client_clinic(location_id).or(schedules.by_staff_home_clinic(location_id))
    end
    schedules = schedules&.uniq&.sort_by(&:date)
    schedules = schedules&.paginate(page: params[:page]) if params[:page].present?
    schedules
  end

  def filter_schedules
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
    schedules
  end

  def set_client_enrollment_service
    @client_enrollment_service = ClientEnrollmentService.find(params[:client_enrollment_service_id]) rescue nil
  end

  def update_client_enrollment_service
    @schedule&.client_enrollment_service = ClientEnrollmentService.find_by(id: params[:client_enrollment_service_id])
    @schedule&.save
  end

  def update_render_service
    RenderAppointments::RenderScheduleManualOperation.call(@schedule&.id, params[:catalyst_soap_note_id], current_user) if (params[:is_rendered].to_bool.true? || params[:status]=='rendered') && @schedule&.date<Time.current.to_date
  end

  def update_scheduling
    @schedule&.update(scheduling_params)
    @schedule&.updator_id = current_user.id
    update_render_service if params[:is_rendered].present? || params[:status]=='rendered'
    update_client_enrollment_service if params[:client_enrollment_service_id].present?
    @schedule.mail_change_appoitment if @schedule&.save
  end

  def update_scheduling_when_bcba
    @schedule&.update(scheduling_params_when_bcba)
    @schedule&.updator_id = current_user.id
    update_render_service if params[:is_rendered].present? || params[:status]=='rendered'
    update_client_enrollment_service if params[:client_enrollment_service_id].present?    
    @schedule&.save
  end

  def is_create_request_via_catalyst_data
    return true if params[:catalyst_data_id].present?

    false
  end

  def update_data
    catalyst_data = CatalystData.find(params[:catalyst_data_id]) rescue nil
    schedules = Scheduling.where('catalyst_data_ids @> ?', "{#{catalyst_data&.id}}").where.not(id: @schedule&.id)
    schedules&.each do |schedule|
      schedule&.catalyst_data_ids = schedule&.catalyst_data_ids&.uniq
      schedule&.catalyst_data_ids.delete(catalyst_data&.id)
      schedule.save(validate: false)
      RenderAppointments::RenderScheduleOperation.call(schedule&.id) if !schedule&.unrendered_reason&.include?('units_does_not_match')
    end
    @schedule&.start_time = catalyst_data&.start_time
    @schedule&.end_time = catalyst_data&.end_time
    @schedule&.units = catalyst_data&.units if catalyst_data&.units.present?
    @schedule&.minutes = catalyst_data&.minutes if catalyst_data&.minutes.present?
    @schedule&.date = catalyst_data&.date
    @schedule&.catalyst_data_ids.push(catalyst_data&.id)
    @schedule&.catalyst_data_ids.uniq!
    if current_user.role_name=='super_admin' || current_user.role_name=='executive_director' || current_user.role_name=='client_care_coordinator' || current_user.role_name=='Clinical Director'
      @schedule&.save(validate: false)
      create_or_update_soap_note(catalyst_data)
      catalyst_data&.update(system_scheduling_id: @schedule&.id)
      RenderAppointments::RenderScheduleOperation.call(@schedule&.id)
    else
      @schedule&.save
      if @schedule&.save
        create_or_update_soap_note(catalyst_data)
        catalyst_data&.update(system_scheduling_id: @schedule&.id)
        RenderAppointments::RenderScheduleOperation.call(@schedule&.id)
      end
    end
  end

  def create_or_update_soap_note(catalyst_data)
    soap_note = SoapNote.find_by(catalyst_data_id: catalyst_data&.id)
    if soap_note.blank?
      soap_note = SoapNote.new(catalyst_data_id: catalyst_data&.id)
      soap_note&.add_date = catalyst_data&.date
      soap_note&.note = catalyst_data&.note
      soap_note&.creator_id = @schedule.staff_id
      soap_note&.synced_with_catalyst = true
      soap_note&.bcba_signature = true if catalyst_data&.bcba_signature.present?
      soap_note&.clinical_director_signature = true if catalyst_data&.clinical_director_signature.present?
      soap_note&.caregiver_signature = true if catalyst_data&.caregiver_signature.present?
      if @schedule&.staff&.role_name=='rbt' && catalyst_data&.provider_signature.present?
        soap_note&.rbt_signature = true
      elsif @schedule&.staff&.role_name=='bcba' && catalyst_data&.provider_signature.present?
        soap_note&.bcba_signature = true
      end
      soap_note&.save(validate: false)
    end
    soap_note&.client_id = @schedule&.client_enrollment_service&.client_enrollment&.client_id
    soap_note&.scheduling_id = @schedule&.id
    soap_note&.save(validate: false)
  end

  def delete_scheduling
    CatalystData.where(system_scheduling_id: @schedule.id)&.update_all(system_scheduling_id: nil)
    @schedule&.destroy
  end

  def check_units
    #update_units_columns(@schedule.client_enrollment_service)
    if (params[:status]=='scheduled' && !@schedule.scheduled? && !@schedule.rendered?) && @schedule.client_enrollment_service.left_units<params[:units].to_f
      @schedule&.errors&.add(:units, "left in authorization are not enough to update #{@schedule&.status} appointment to scheduled.")
      return false
    elsif params[:units].present? && params[:units].to_f>@schedule&.units && @schedule&.client_enrollment_service&.left_units<(params[:units].to_f-@schedule&.units)
      @schedule&.errors&.add(:units, 'left in authorization are not enough to update the units of appointment.')
      return false
    end
    true
  end

  def update_status
    if params[:status]=='rendered'
      if current_user.role_name=='super_admin'
        update_scheduling 
        update_render_service
      else
        @schedule&.errors&.add(:schedule, 'You are not authorized to render appointment manually.')
        return false
      end
    elsif @schedule.rendered? && params[:status]!='rendered'
      if current_user.role_name=='super_admin'
        update_scheduling 
        @schedule&.rendered_at = nil
        @schedule&.rendered_by_id = nil
        @schedule&.is_manual_render = false
        @schedule&.save
      else
        @schedule&.errors&.add(:schedule, 'You are not authorized to unrender appointment.')
        return false
      end
    elsif @schedule.draft? && params[:status]!='draft'
      case current_user.role_name
      when 'Clinical Director', 'client_care_coordinator', 'super_admin'
        update_scheduling
      else
        @schedule&.errors&.add(:draft, 'appointments can be confirmed by client care coordinator and clinical director only.')
        return false
      end
    else
      case current_user.role_name
      when 'administrator', 'executive_director', 'Clinical Director', 'client_care_coordinator', 'super_admin'
        update_scheduling 
      when 'bcba'
        update_scheduling_when_bcba
      else
        puts "#{current_user.role_name}"
      end
    end
    true
  end

  def manual_rendering
    @schedule&.update(status: 'rendered',rendered_at: Time.current,is_manual_render: true, rendered_by_id: current_user.id, user: current_user)
  end

  def set_db_time_format
    params[:start_time] = params[:start_time]&.in_time_zone&.strftime("%H:%M") if params[:start_time].present?
    params[:end_time] = params[:end_time]&.in_time_zone&.strftime("%H:%M") if params[:end_time].present?
  end

  def update_staff_legacy_number
    return if params[:legacy_number].blank?
    
    @schedule&.staff&.update(legacy_number: params[:legacy_number])
  end
end
