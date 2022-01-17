class ClientsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client, only: %i[show update]

  def index
    @clients = Client.order(:first_name)
  end

  def show; end

  def create
    @client = Client.new(client_params)
    @client.role = Role.client.first
    @client.save
  end

  def update
    @client.update(client_params)
  end

  private

  def client_params
    arr = %i[first_name last_name status gender email dob clinic_id]
    arr.concat(%i[password password_confirmation]) if params['action']=='create'

    params.permit(arr)
  end

  def set_client
    @client = Client.find(params[:id])
  end
end
