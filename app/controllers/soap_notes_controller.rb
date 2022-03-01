class SoapNotesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
  before_action :set_scheduling
  before_action :set_soap_note, only: :show

  def index
    @soap_notes = @scheduling.soap_notes.order(:add_date)
  end

  def show; end

  def create 
    @soap_note = @scheduling.soap_notes.new(soap_note_params)
    @soap_note.creator_id = current_user.id
    @soap_note.save
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
    params.permit(:note, :add_date)
  end
  # end of private
end
