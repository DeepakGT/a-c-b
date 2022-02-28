class SoapNotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_scheduling

  def create 
    @soap_note = @scheduling.soap_notes.new(soap_note_params)
    @soap_note.creator_id = current_user.id
    @soap_note.save
  end

  private

  def set_scheduling
    @scheduling = Scheduling.find(params[:scheduling_id])
  end

  def soap_note_params
    params.permit(:note, :add_date)
  end
  # end of private
end
