class ClientNotesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
  before_action :set_client
  before_action :set_client_note, only: [:show, :update, :destroy]

  def index
    @client_notes = @client.notes.order(:created_at)
  end

  def create
    @client_note = @client.notes.new(client_note_params)
    set_attachment
    @client_note.save
  end

  def show; end

  def update
    @client_note.update(client_note_params)
    set_attachment
    @client_note.save
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
    params.permit(:note, attachment_attributes: :category)
  end

  def authorize_user
    authorize ClientNote if current_user.role_name!='super_admin'
  end

  def set_attachment
    base64 = params.dig(:attachment_attributes, :base64)
    if base64.present?
      decoded_data = Base64.decode64(base64.split(',')[1])
      @client_note.attachment.file = {filename: 'attachment', io: StringIO.new(decoded_data)}
    end
  end

  # end of private
end
