class CatalystController < ApplicationController
  before_action :authenticate_user!
  # before_action :authorize_user

  def sync_with_catalyst
    @response_data_array = Catalyst::SyncDataOperation.call(params[:start_date], params[:end_date])
  end

  def unmatched_units
    @schedule = Scheduling.find(params[:sceduling_id])
    @catalyst_data = CatalystData.find(params[:catalyst_data_id])
    use_catalyst_units if params[:use_catalyst_units]==true
    use_custom_units if params[:use_custom_units]==true
    create_soap_note
    update_render_service
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
    @schedule.save(validate: false)
  end

  def use_custom_units
    @schedule.units = params[:units] if params[:units].present?
    @schedule.minutes = params[:minutes] if params[:minutes].present?
    @schedule.start_time = params[:start_time] if params[:start_time].present?
    @schedule.end_time = params[:end_time] if params[:end_time].present?
    @schedule.save(validate: false)
  end

  def create_soap_note
    soap_note = @schedule.soap_notes.new(add_date: @catalyst_data.date, note: @catalyst_data.note, creator_id: @schedule.staff_id)
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
        soap_notes.each do |soap_note|
          if soap_note.bcba_signature.to_bool.false?
            schedule.unrendered_reason.push('bcba_signature_absent')
            schedule.unrendered_reason = schedule.unrendered_reason.uniq
            schedule.save(validate: false)
          end
          if soap_note.clinical_director_signature.to_bool.false? 
            schedule.unrendered_reason.push('clinical_director_signature_absent')
            schedule.unrendered_reason = schedule.unrendered_reason.uniq
            schedule.save(validate: false)
          end
          if soap_note.rbt_signature.to_bool.false?  && schedule.staff.role_name=='rbt'
            schedule.unrendered_reason.push('rbt_signature_absent')
            schedule.unrendered_reason = schedule.unrendered_reason.uniq
            schedule.save(validate: false)
          end
          if !soap_note.signature_file.attached? && soap_note.caregiver_signature!=true
            schedule.unrendered_reason.push('caregiver_signature_absent')
            schedule.unrendered_reason = schedule.unrendered_reason.uniq
            schedule.save(validate: false)
          end
          if @schedule.unrendered_reason.blank?
            @schedule.is_rendered = true
            @schedule.save(validate: false)
            break
          end
        end
      else
        @schedule.unrendered_reason.push('soap_note_absent')
        schedule.unrendered_reason = schedule.unrendered_reason.uniq
        @schedule.save(validate: false)
      end
    end
  end
end
