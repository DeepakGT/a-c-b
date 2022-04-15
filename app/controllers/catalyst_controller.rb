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
    update_render_service
  end

  def create_appointment
    @catalyst_data = CatalystData.find(params[:catalyst_data_id])
    staff = Staff.find_by(first_name: @catalyst_data.staff_first_name, last_name: @catalyst_data.staff_last_name)
    @schedule = Scheduling.new(date: @catalyst_data.date, start_time: @catalyst_data.start_time, 
                               end_time: @catalyst_data.end_time, units: @catalyst_data.units, staff_id: staff.id,
                              client_enrollment_service_id: params[:client_enrollment_service_id])
    @schedule.service_address_id = params[:service_address_id] if params[:service_address_id].present?
    @schedule.status = params[:status] if params[:status].present?
    @schedule.catalyst_data_ids.push(@catalyst_data.id)
    @schedule.save(validate: false)
    @catalyst_data.update(is_appointment_found: true, system_scheduling_id: @schedule.id, multiple_schedulings_ids: [])
    create_soap_note
    update_render_service
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
      update_render_service
    end
  end

  def catalyst_data_with_multiple_appointments
    @catalyst_data = CatalystData.find(params[:id])
    @schedules = Scheduling.where(id: @catalyst_data.multiple_schedulings_ids)
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
    @schedule.save(validate: false)
  end

  def create_soap_note
    soap_note = @schedule.soap_notes.new(add_date: @catalyst_data.date, note: @catalyst_data.note, creator_id: @schedule.staff_id, synced_with_catalyst: true)
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

  def update_render_service
    if @schedule.date<Time.now.to_date
      if @schedule.soap_notes.any?
        @schedule.soap_notes.each do |soap_note|
          @schedule.unrendered_reason = []
          @schedule.save(validate: false)
          if soap_note.bcba_signature.to_bool.false?
            @schedule.unrendered_reason.push('bcba_signature_absent')
            @schedule.unrendered_reason = @schedule.unrendered_reason.uniq
            @schedule.save(validate: false)
          end
          if soap_note.clinical_director_signature.to_bool.false? 
            @schedule.unrendered_reason.push('clinical_director_signature_absent')
            @schedule.unrendered_reason = @schedule.unrendered_reason.uniq
            @schedule.save(validate: false)
          end
          if soap_note.rbt_signature.to_bool.false?  && @schedule.staff.role_name=='rbt'
            @schedule.unrendered_reason.push('rbt_signature_absent')
            @schedule.unrendered_reason = @schedule.unrendered_reason.uniq
            @schedule.save(validate: false)
          end
          if !soap_note.signature_file.attached? && soap_note.caregiver_signature!=true
            @schedule.unrendered_reason.push('caregiver_signature_absent')
            @schedule.unrendered_reason = @schedule.unrendered_reason.uniq
            @schedule.save(validate: false)
          end
          if @schedule.unrendered_reason.blank?
            @schedule.is_rendered = true
            @schedule.save(validate: false)
            break
          end
        end
      else
        @schedule.unrendered_reason.push('soap_note_absent')
        @schedule.unrendered_reason = @schedule.unrendered_reason.uniq
        @schedule.save(validate: false)
      end
    end
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
