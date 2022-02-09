class ClientsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
  before_action :set_client, only: %i[show update]

  def index
    @clients = Client.order(:first_name).paginate(page: params[:page])
  end

  def show; end

  def create
    @client = Client.new(client_params)
    @client.password = 'Abcdef_1' if !params[:password].present?
    @client.save_with_exception_handler
  end

  def update
    @client.update_with_exception_handler(client_params)
  end

  private

  def client_params
    arr = %i[first_name last_name payer_status status gender email dob clinic_id preferred_language disqualified dq_reason note]

    arr.concat(%i[password password_confirmation]) if params['action']=='create'

    arr.concat([addresses_attributes: 
                %i[id line1 line2 line3 zipcode city state country address_type addressable_type addressable_id],
                phone_number_attributes: %i[phone_type number], note_attributes: [:note, attachments_attributes: %i[category base64]]])

    params.permit(arr)
  end

  def set_client
    @client = Client.find(params[:id])
  end

  def authorize_user
    authorize Client if current_user.role_name!='super_admin'
  end
  # end of private

end
