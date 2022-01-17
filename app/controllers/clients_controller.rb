class ClientsController < ApplicationController
  before_action :authenticate_user!

  def index
    @clients = Client.order(:first_name)
  end

  def create
    @client = Client.new(client_params)
    @client.role = Role.client.first
    @client.save
  end

  def update
    @client = Client.find(params[:id])
    @client.update(client_params)
  end

  private

  def client_params
    arr = [:first_name, :last_name, :status, :gender, :email, :dob, :clinic_id]
    arr.concat([:password, :password_confirmation]) if params['action']=='create'

    params.permit(arr)
  end
end
