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
    set_sign
    # @soap_note.caregiver_sign.attach(params[:caregiver_sign])
    @soap_note.creator_id = current_user.id
    @soap_note.save
  end

  def update
    @soap_note.update(soap_note_params)
    set_sign
    # @soap_note.caregiver_sign.attach(params[:caregiver_sign])
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
    params.permit(:note, :add_date, :rbt_sign, :bcba_sign, :clinical_director_sign, :caregiver_sign)
  end

  def set_sign
    if params[:rbt_sign].to_bool.true?
      @soap_note.rbt_sign_name = "#{current_user.first_name} #{current_user.last_name}"
      @soap_note.rbt_sign_date = Time.now.to_date
    elsif params[:rbt_sign].present?
      @soap_note.rbt_sign_name = nil
      @soap_note.rbt_sign_date = nil
    end
    if params[:bcba_sign].to_bool.true?
      @soap_note.bcba_sign_name = "#{current_user.first_name} #{current_user.last_name}"
      @soap_note.bcba_sign_date = Time.now.to_date
    elsif params[:bcba_sign].present?
      @soap_note.bcba_sign_name = nil
      @soap_note.bcba_sign_date = nil
    end
    if params[:clinical_director_sign].to_bool.true?
      @soap_note.clinical_director_sign_name = "#{current_user.first_name} #{current_user.last_name}"
      @soap_note.clinical_director_sign_date = Time.now.to_date
    elsif params[:clinical_director_sign].present?
      @soap_note.clinical_director_sign_name = nil
      @soap_note.clinical_director_sign_date = nil
    end
  end
  # end of private
end
