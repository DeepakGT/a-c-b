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
    update_soap_note
    update_audit_action
    #ClientEnrollmentServices::UpdateUnitsColumnsOperation.call(@schedule.client_enrollment_service) if @schedule.client_enrollment_service.present?
    RenderAppointments::RenderScheduleOperation.call(@schedule.id) if @schedule.date<Time.current.to_date
  end

  def assign_catalyst_note
    @schedule = Scheduling.find(params[:scheduling_id])
    @catalyst_data = CatalystData.find(params[:catalyst_data_id])
    @schedule.catalyst_data_ids.push("#{@catalyst_data.id}") if !@schedule.catalyst_data_ids.include?("#{@catalyst_data.id}")
    @schedule.catalyst_data_ids.uniq!
    @schedule.save(validate: false)
    update_catalyst_data_ids
    @catalyst_data.update(system_scheduling_id: @schedule.id)
    check_units
    update_soap_note
    if (@schedule.date<Time.current.to_date) && !(@schedule.unrendered_reason.include?('units_does_not_match'))
      RenderAppointments::RenderScheduleOperation.call(@schedule.id) 
    end
  end

  def catalyst_data_with_multiple_appointments
    @catalyst_data = CatalystData.find(params[:id])
    # @schedules = Scheduling.where(id: @catalyst_data.multiple_schedulings_ids)
    @schedules = []
  end

  def appointments_list
    @catalyst_data = CatalystData.find(params[:catalyst_data_id])
    schedules = matching_existing_appointments_list
    @schedules = schedules.uniq.sort_by(&:start_time)
  end

  def sync_soap_notes
    workers = Sidekiq::Workers.new
    if workers.nil?
      SyncClientSoapNotesJob.perform_later
      @success = true
    else
      @success = false
    end
  end

  def appointment_with_multiple_soap_notes
    @schedule = Scheduling.find(params[:scheduling_id])
    @selected_catalyst_data = CatalystData.where(id: params[:selected_catalyst_data_ids])
    update_selected_catalyst_data
    update_unselected_catalyst_data
    soap_notes = SoapNote.where(catalyst_data_id: @selected_catalyst_data&.ids)
    soap_notes.update_all(scheduling_id: @schedule.id, client_id: @schedule.client_enrollment_service.client_enrollment.client_id)
    re_render_appointment
  end

  def delete_catalyst_soap_note
    @catalyst_data = CatalystData.find(params[:catalyst_data_id])
    @catalyst_data.update(is_deleted_from_connect: true)
  end

  def matching_appointments_list
    @catalyst_data = CatalystData.find(params[:catalyst_data_id])
    schedules = matching_existing_appointments_list
    schedule = best_match_appointment(schedules)
    @schedules = Array.new(1, schedule).compact
  end

  private

  def authorize_user
    authorize Catalyst if current_user.role_name!='super_admin'
  end

  def use_catalyst_units
    @schedule.units = @catalyst_data.units
    @schedule.minutes = @catalyst_data.minutes
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
    elsif params[:minutes].present? && params[:units].blank?
      rem = @schedule.minutes%15
      if rem == 0
        @schedule.units = @schedule.minutes/15
      elsif rem < 8
        @schedule.units = (@schedule.minutes - rem)/15
      else
        @schedule.units = (@schedule.minutes + 15 - rem)/15
      end 
    end
    @schedule.save(validate: false)
  end

  def update_soap_note
    soap_note = SoapNote.find_or_initialize_by(catalyst_data_id: @catalyst_data.id)
    soap_note.add_date = @catalyst_data.date
    soap_note.note = @catalyst_data.note
    soap_note.creator_id = @schedule.staff_id
    soap_note.synced_with_catalyst = true
    soap_note.scheduling_id = @schedule.id
    soap_note.client_id = @schedule.client_enrollment_service.client_enrollment.client_id
    soap_note.bcba_signature = true if @catalyst_data.bcba_signature.present?
    soap_note.clinical_director_signature = true if @catalyst_data.clinical_director_signature.present?
    soap_note.caregiver_signature = true if @catalyst_data.caregiver_signature.present?
    if @schedule.staff&.role_name=='rbt' && @catalyst_data.provider_signature.present?
      soap_note.rbt_signature = true
    elsif @schedule.staff&.role_name=='bcba' && @catalyst_data.provider_signature.present?
      soap_note.bcba_signature = true
    end
    soap_note.save(validate: false)
  end

  def check_units
    # @schedule.is_rendered = false
    @schedule.rendered_at = nil
    @schedule.status = 'Scheduled'
    @schedule.save(validate: false)
    catalyst_data = CatalystData.where(id: @schedule.catalyst_data_ids.uniq)
    total_units = catalyst_data.pluck(:units).sum
    if @schedule.units != total_units
      @schedule.unrendered_reason = ['units_does_not_match']
      @schedule.save(validate: false)
    end
  end

  def update_catalyst_data_ids
    appointments = Scheduling.where.not(id: @schedule.id).where('catalyst_data_ids @> ?', "{#{@catalyst_data.id}}")
    appointments.each do |appointment|
      appointment.catalyst_data_ids.uniq!
      appointment.catalyst_data_ids.delete("#{@catalyst_data.id}")
      appointment.save(validate: false)
      RenderAppointments::RenderScheduleOperation.call(appointment.id) if appointment.present? && !(appointment.unrendered_reason.include?('units_does_not_match'))
    end
  end

  def re_render_appointment
    @schedule.catalyst_data_ids = @selected_catalyst_data.ids
    @schedule.unrendered_reason = []
    @schedule.is_soap_notes_assigned = true
    @schedule.save(validate: false)
    catalyst_data = CatalystData.where(id: @schedule.catalyst_data_ids)
    total_units = catalyst_data.pluck(:units).sum
    if @schedule.units!=total_units
      @schedule.unrendered_reason = ['units_does_not_match']
      @schedule.save(validate: false)
    end
    if !@schedule.unrendered_reason.include?('units_does_not_match') && !@schedule.unrendered_reason.include?('multiple_soap_notes_found') && !@schedule.unrendered_reason.include?('multiple_soap_notes_of_different_locations_found')
      RenderAppointments::RenderScheduleOperation.call(@schedule.id)
    end
  end

  def update_unselected_catalyst_data
    unselected_catalyst_data_ids = (@schedule.catalyst_data_ids - @selected_catalyst_data.ids.map(&:to_s)).uniq
    unselected_catalyst_data = CatalystData.where(id: unselected_catalyst_data_ids)
    unselected_catalyst_data.each do |catalyst_data|
      # catalyst_data.multiple_schedulings_ids = catalyst_data.multiple_schedulings_ids.uniq
      # catalyst_data.multiple_schedulings_ids.delete(@schedule.id) if (catalyst_data.multiple_schedulings_ids.present? && catalyst_data.multiple_schedulings_ids.include?(@schedule.id))
      catalyst_data.system_scheduling_id = nil if catalyst_data.system_scheduling_id==@schedule.id
      catalyst_data.save(validate: false)
      # catalyst_data.is_appointment_found = false if catalyst_data.multiple_schedulings_ids.blank? && catalyst_data.system_scheduling_id.blank?
      catalyst_data.save(validate: false)
      soap_note = SoapNote.find_by(catalyst_data_id: catalyst_data.id)
      if soap_note.present? && soap_note.scheduling_id==@schedule.id
        soap_note.client_id = nil
        soap_note.scheduling_id = nil
        soap_note.save(validate: false)
      end
    end
  end

  def update_selected_catalyst_data
    @selected_catalyst_data.each do |catalyst_data|
      # catalyst_data.multiple_schedulings_ids = []
      catalyst_data.system_scheduling_id = @schedule.id
      # catalyst_data.is_appointment_found = true
      catalyst_data.save(validate: false)
    end
  end

  def matching_existing_appointments_list
    client = Client.where(catalyst_patient_id: @catalyst_data.catalyst_patient_id)
    if client.count==1
      client = client.first
    elsif client.count>1
      client = client.find_by(status: 'active')
    else
      client = Client.find_by(catalyst_patient_id: @catalyst_data.catalyst_patient_id)
    end
    staff = Staff.where(catalyst_user_id: @catalyst_data.catalyst_user_id)
    if staff.count==1
      staff = staff.first
    elsif staff.count>1
      staff = staff.find_by(status: 'active')
    else
      staff = Staff.find_by(catalyst_user_id: @catalyst_data.catalyst_user_id)
    end
    schedules = Scheduling.joins(client_enrollment_service: :client_enrollment).by_client_ids(client&.id).by_staff_ids(staff&.id).on_date(@catalyst_data.date)
    schedules = schedules.where.not(rendered_at: nil).where(is_manual_render: true).left_outer_joins(:soap_notes).group('schedulings.id').having('count(soap_notes.*) = ?', 0)
                         .or(schedules.by_status)
    schedules
  end

  def best_match_appointment(schedules)
    if schedules.length==1
      schedule = schedules.first
    elsif schedules.length>1
      filtered_schedules = schedules.where(start_time: @catalyst_data.start_time, end_time: @catalyst_data.end_time, units: @catalyst_data.units)
      if filtered_schedules.length==1
        schedule = filtered_schedules.first
      elsif filtered_schedules.length>1
        service_display_code = @catalyst_data.response['templateName'][-10..-6]
        filtered_schedules = filtered_schedules.joins(client_enrollment_service: :service).where('services.display_code': service_display_code)
        if filtered_schedules.length==1
          schedule = filtered_schedules.first
        elsif filtered_schedules.length>1
          filtered_schedules_by_soap_notes = filtered_schedules.left_outer_joins(:soap_notes).group('schedulings.id').having('count(soap_notes.*) = ?', 0)
          if filtered_schedules_by_soap_notes.length>=1
            schedule = filtered_schedules_by_soap_notes.first
          end
        end
      end 
      if schedule.nil?
        filtered_schedules = []
        schedules.each do |appointment|
          min_start_time = (appointment.start_time.to_time-15.minutes)
          max_start_time = (appointment.start_time.to_time+15.minutes)
          min_end_time = (appointment.end_time.to_time-15.minutes)
          max_end_time = (appointment.end_time.to_time+15.minutes)
          if (min_start_time..max_start_time).include?(@catalyst_data.start_time.to_time) && (min_end_time..max_end_time).include?(@catalyst_data.end_time.to_time)
            filtered_schedules.push(appointment)
          end
        end
        if filtered_schedules.length==1
          schedule = filtered_schedules.first
        elsif filtered_schedules.length>1
          service_display_code = catalyst_data.response['templateName'][-10..-6]
          filtered_schedules = filtered_schedules.map{|schedule| schedule if schedule.client_enrollment_service.service.display_code==service_display_code}.compact
          if filtered_schedules.length==1
            schedule = filtered_schedules.first
          elsif filtered_schedules.length>1
            filtered_schedules = filtered_schedules.sort_by(&:minutes)
            schedule = filtered_schedules.first
          end
        end
      end
    else
      schedule = nil
    end
    schedule
  end

  def update_audit_action
    audit = @schedule.audits.last
    if params[:use_catalyst_units].to_bool.true?
      audit.update(action: 'use catalyst units')
    elsif params[:use_custom_units].to_bool.true?
      audit.update(action: 'use custom units')
    end
  end
end
