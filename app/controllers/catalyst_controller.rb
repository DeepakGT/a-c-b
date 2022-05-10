class CatalystController < ApplicationController
  before_action :authenticate_user!
  # before_action :authorize_user

  def sync_data
    @response_data_array = Catalyst::SyncDataOperation.call(params[:start_date], params[:end_date])
  end

  def update_appointment_units
    @schedule = Scheduling.find(params[:scheduling_id])
    @catalyst_data = CatalystData.find(params[:catalyst_data_id])
    use_catalyst_units if params[:use_catalyst_units].to_bool.true?
    use_abac_units if params[:use_abac_units].to_bool.true?
    use_custom_units if params[:use_custom_units].to_bool.true?
    create_soap_note
    RenderAppointments::RenderScheduleOperation.call(@schedule.id) if @schedule.date<Time.current.to_date
  end

  def assign_catalyst_note
    @schedule = Scheduling.find(params[:scheduling_id])
    @catalyst_data = CatalystData.find(params[:catalyst_data_id])
    @schedule.catalyst_data_ids.push(@catalyst_data.id)
    @schedule.save(validate: false)
    temp_var = 0
    temp_var = 1 if @schedule.unrendered_reason.include?('units_does_not_match')
    @catalyst_data.update(is_appointment_found: true, system_scheduling_id: @schedule.id, multiple_schedulings_ids: [])
    @checked_units = false
    check_units if @catalyst_data.id == @schedule.catalyst_data_ids.max.to_i
    if (!(@schedule.unrendered_reason.include?('units_does_not_match')) &&  @checked_units==false && temp_var==0) || temp_var==1
      create_soap_note
      RenderAppointments::RenderScheduleOperation.call(@schedule.id) if @schedule.date<Time.current.to_date
    end
  end

  def catalyst_data_with_multiple_appointments
    @catalyst_data = CatalystData.find(params[:id])
    @schedules = Scheduling.where(id: @catalyst_data.multiple_schedulings_ids)
  end

  def appointments_list
    @catalyst_data = CatalystData.find(params[:catalyst_data_id])
    schedules = Scheduling.on_date(@catalyst_data.date)
    schedules = schedules.joins(client_enrollment_service: {client_enrollment: :client}).by_client_clinic(params[:location_id]) if params[:location_id].present?
    @schedules = schedules.order(:start_time)
  end

  def sync_soap_notes
    workers = Sidekiq::Workers.new
    if(workers.size == 0)
      SyncClientSoapNotesJob.perform_later
      @success = true
    else
      @success = false
    end
  end

  private

  def authorize_user
    authorize Catalyst if current_user.role_name!='super_admin'
  end

  def use_catalyst_units
    @schedule.units = @catalyst_data.units if @schedule.units.present?
    @schedule.minutes = @catalyst_data.minutes if @schedule.minutes.present?
    @schedule.start_time = @catalyst_data.start_time
    @schedule.end_time = @catalyst_data.end_time
    @schedule.unrendered_reason = []
    @schedule.save(validate: false)
  end

  def use_abac_units
    @schedule.unrendered_reason = []
    @schedule.save(validate: false)
  end

  def use_custom_units
    @schedule.units = params[:units] if params[:units].present?
    @schedule.minutes = params[:minutes] if params[:minutes].present?
    @schedule.start_time = params[:start_time] if params[:start_time].present?
    @schedule.end_time = params[:end_time] if params[:end_time].present?
    @schedule.unrendered_reason = []
    if params[:units].present? && params[:minutes].blank?
      @schedule.minutes = @schedule.units*15
    elsif params[:minutes].present? && params[:minutes].blank?
      rem = @schedule.minutes%15
      if rem == 0
        @schedule.units = @schedule.minutes/15
      else
        if rem < 8
          @schedule.units = (@schedule.minutes - rem)/15
        else
          @schedule.units = (@schedule.minutes + 15 - rem)/15
        end
      end 
    end
    @schedule.save(validate: false)
  end

  def create_soap_note
    soap_note = @schedule.soap_notes.find_or_initialize_by(catalyst_data_id: @catalyst_data.id)
    soap_note.add_date = @catalyst_data.date
    soap_note.note = @catalyst_data.note
    soap_note.creator_id = @schedule.staff_id
    soap_note.synced_with_catalyst = true
    soap_note.bcba_signature = true if @catalyst_data.bcba_signature.present?
    soap_note.clinical_director_signature = true if @catalyst_data.clinical_director_signature.present?
    soap_note.caregiver_signature = true if @catalyst_data.caregiver_signature.present?
    if @schedule.staff.role_name=='rbt' && @catalyst_data.provider_signature.present?
      soap_note.rbt_signature = true
    elsif @schedule.staff.role_name=='bcba' && @catalyst_data.provider_signature.present?
      soap_note.bcba_signature = true
    end
    soap_note.save(validate: false)
  end

  def check_units
    @checked_units = true
    @schedule.is_rendered = false
    @schedule.save(validate: false)
    min_start_time = (@catalyst_data.start_time.to_time-15.minutes)
    max_start_time = (@catalyst_data.start_time.to_time+15.minutes)
    min_end_time = (@catalyst_data.end_time.to_time-15.minutes)
    max_end_time = (@catalyst_data.end_time.to_time+15.minutes)
    if (min_start_time..max_start_time).include?(@schedule.start_time.to_time) && (min_end_time..max_end_time).include?(@schedule.end_time.to_time)
      @schedule.start_time = catalyst_data.start_time 
      @schedule.end_time = catalyst_data.end_time 
      @schedule.units = catalyst_data.units if @schedule.units.present?
      @schedule.minutes = catalyst_data.minutes if @schedule.minutes.present?
      @schedule.save(validate: false)
    else
      @schedule.unrendered_reason.push('units_does_not_match')
      @schedule.save(validate: false)
    end
  end
end
