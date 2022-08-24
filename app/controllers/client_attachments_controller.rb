class ClientAttachmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user, except: %i[show]
  before_action :set_client
  before_action :set_attachment, only: %i[show update destroy]

  def index
    @attachments = @client&.attachments&.order(:created_at)
  end

  def show
    @attachment
    authorize @attachment if current_user.role_name != 'super_admin'
  end

  def create
    @attachment = @client&.attachments&.create(attachment_params)
  end

  def update
    @attachment&.update(attachment_params)
  end

  def destroy
    @attachment&.destroy
  end

  private

  def authorize_user
    authorize Attachment if current_user.role_name != 'super_admin'
  end

  def set_client
    @client = Client.find(params[:client_id]) rescue nil
  end

  def set_attachment
    @attachment = @client.attachments.find(params[:id]) rescue nil
  end

  def attachment_params
    params.permit(:base64, :file_name, :attachment_category_id, permissions: [])
  end

end
