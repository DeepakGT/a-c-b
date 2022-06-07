class SoapNotesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
  before_action :set_scheduling
  before_action :set_soap_note, only: %i[show update destroy]

  def index
    @soap_notes = @scheduling.soap_notes.order(:add_date)
  end

  def show; end

  def create 
    SoapNote.transaction do
      @soap_note = @scheduling.soap_notes.new(soap_note_params)
      set_signature
      @soap_note.user = current_user
      @soap_note.creator_id = current_user.id
      @soap_note.client_id = @scheduling.client_enrollment_service.client_enrollment.client.id
      @soap_note.save
      RenderAppointments::RenderBySoapNoteOperation.call(@soap_note.id) if @scheduling.date<Time.current.to_date
    end
  end

  def update
    SoapNote.transaction do
      update_signature
      @soap_note.user = current_user
      @soap_note.update(soap_note_params)
      RenderAppointments::RenderBySoapNoteOperation.call(@soap_note.id) if @scheduling.date<Time.current.to_date
    end
  end

  def destroy
    @soap_note.destroy
  end

  private

  def authorize_user
    authorize SoapNote if current_user.role_name!='super_admin'
  end

  def set_soap_note
    @soap_note = @scheduling.soap_notes.find(params[:id])
  end

  def set_scheduling
    @scheduling = Scheduling.find(params[:scheduling_id])
  end

  def soap_note_params
    params.permit(:note, :add_date, :caregiver_sign, :add_time)
  end

  def set_signature
    if params[:rbt_sign].to_bool.true?
      @soap_note.rbt_signature = true
      @soap_note.rbt_signature_author_name = "#{current_user.first_name} #{current_user.last_name}"
      @soap_note.rbt_signature_date = Time.current.to_date
    elsif params[:rbt_sign]==false
      @soap_note.rbt_signature = false
      @soap_note.rbt_signature_author_name = nil
      @soap_note.rbt_signature_date = nil
    end
    if params[:bcba_sign].to_bool.true?
      @soap_note.bcba_signature = true
      @soap_note.bcba_signature_author_name = "#{current_user.first_name} #{current_user.last_name}"
      @soap_note.bcba_signature_date = Time.current
    elsif params[:bcba_sign]==false
      @soap_note.bcba_signature = false
      @soap_note.bcba_signature_author_name = nil
      @soap_note.bcba_signature_date = nil
    end
    if params[:clinical_director_sign].to_bool.true?
      @soap_note.clinical_director_signature = true
      @soap_note.clinical_director_signature_author_name = "#{current_user.first_name} #{current_user.last_name}"
      @soap_note.clinical_director_signature_date = Time.current.to_date
    elsif params[:clinical_director_sign]==false
      @soap_note.clinical_director_signature = false
      @soap_note.clinical_director_signature_author_name = nil
      @soap_note.clinical_director_signature_date = nil
    end
    @soap_note.caregiver_signature_datetime = DateTime.current if params[:caregiver_sign].present?
  end

  def update_signature
    if current_user.role_name=='super_admin' || current_user.role_name=='executive_director'
      set_signature
    else
      if params[:rbt_sign].to_bool.true? && @soap_note.rbt_signature.to_bool.false?
        @soap_note.rbt_signature = true
        @soap_note.rbt_signature_author_name = "#{current_user.first_name} #{current_user.last_name}"
        @soap_note.rbt_signature_date = Time.current.to_date
      end
      if params[:bcba_sign].to_bool.true? && @soap_note.bcba_signature.to_bool.false?
        @soap_note.bcba_signature = true
        @soap_note.bcba_signature_author_name = "#{current_user.first_name} #{current_user.last_name}"
        @soap_note.bcba_signature_date = Time.current
      end
      if params[:clinical_director_sign].to_bool.true? && @soap_note.clinical_director_signature.to_bool.false?
        @soap_note.clinical_director_signature = true
        @soap_note.clinical_director_signature_author_name = "#{current_user.first_name} #{current_user.last_name}"
        @soap_note.clinical_director_signature_date = Time.current.to_date
      end
      @soap_note.caregiver_signature_datetime = DateTime.current if params[:caregiver_sign].present? && !@soap_note.signature_file.attached?
    end
  end
  # end of private
end
