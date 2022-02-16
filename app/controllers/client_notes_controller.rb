class ClientNotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client
  before_action :set_client_note, only: [:show, :update, :destroy]
  before_action :authorize_user

  def index
    @client_notes = @client.notes.order(:created_at)
  end

  def create
    @client_note = @client.notes.new(client_note_params)
    set_creator_id
    @client_note.save
  end

  def show; end

  def update
    @client_note.update(client_note_params)
  end

  def destroy
    @client_note.destroy
  end

  private
  
  def set_client
    @client = Client.find(params[:client_id])
  end

  def set_client_note
    @client_note = @client.notes.find(params[:id])
  end

  def client_note_params
    params.permit(:note, :add_date)
  end

  def authorize_user
    if current_user.role_name!='super_admin'
      if params[:action]=='destroy'
        authorize @client_note 
      else
        authorize ClientNote 
      end
    end
  end

  def set_creator_id
    @client_note.creator_id = current_user.id
  end
  # end of private
end
