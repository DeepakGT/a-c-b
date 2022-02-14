class ClientAttachmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client
  before_action :set_attachment, only: %i[show update destroy]

  def index
    @attachments = @client.attachments.order(:created_at)
  end

  def show; end

  def create
    @attachment = @client.attachments.create(attachment_params)
  end

  def update
    @attachment.update(attachment_params)
  end

  def destroy
    @attachment.destroy
  end

  private

  def set_client
    @client = Client.find(params[:client_id])
  end

  def set_attachment
    @attachment = @client.attachments.find(params[:id])
  end

  def attachment_params
    params.permit(:category, :base64)
  end
  # end of private
end
