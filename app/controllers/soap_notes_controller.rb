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
    @soap_note = @scheduling.soap_notes.new(soap_note_params)
    set_signature
    @soap_note.creator_id = current_user.id
    @soap_note.save
  end

  def update
    @soap_note.update(soap_note_params)
    set_signature
    @soap_note.save
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
    params.permit(:note, :add_date, :rbt_signature, :bcba_signature, :clinical_director_signature, :caregiver_signature)
  end

  def set_signature
    if params[:rbt_signature].to_bool.true?
      @soap_note.rbt_signature_author_name = "#{current_user.first_name} #{current_user.last_name}"
      @soap_note.rbt_signature_date = Time.now.to_date
    elsif params[:rbt_signature].present?
      @soap_note.rbt_signature_author_name = nil
      @soap_note.rbt_signature_date = nil
    end
    if params[:bcba_signature].to_bool.true?
      @soap_note.bcba_signature_author_name = "#{current_user.first_name} #{current_user.last_name}"
      @soap_note.bcba_signature_date = Time.now.to_date
    elsif params[:bcba_signature].present?
      @soap_note.bcba_signature_author_name = nil
      @soap_note.bcba_signature_date = nil
    end
    if params[:clinical_director_signature].to_bool.true?
      @soap_note.clinical_director_signature_author_name = "#{current_user.first_name} #{current_user.last_name}"
      @soap_note.clinical_director_signature_date = Time.now.to_date
    elsif params[:clinical_director_signature].present?
      @soap_note.clinical_director_signature_author_name = nil
      @soap_note.clinical_director_signature_date = nil
    end
    if params[:caregiver_signature].present?
      @soap_note.caregiver_signature_datetime = DateTime.now
    end
  end
  # end of private
end
