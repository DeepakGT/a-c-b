class ClientServiceAddressesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client
  before_action :set_service_address, only: %i[show update destroy]

  def index
    @service_addresses = @client.addresses.by_service_address.order(is_default: :desc)
  end

  def create
    @service_address = @client.addresses.new(service_address_params)
    @service_address.address_type = 'service_address'
    set_default if params[:is_default].present?
    @service_address.save
  end

  def show; end

  def update
    set_default if params[:is_default].present?
    @service_address.update(service_address_params)
  end

  def destroy
    @service_address.destroy
  end

  private

  def set_client
    @client = Client.find(params[:client_id])
  end

  def service_address_params
    params.permit(:line1, :line2, :line3, :zipcode, :city, :state, :country, :is_default, :address_name, :is_hidden)
  end

  def set_default
    if params[:is_default].to_bool.false?
      @service_address.is_default = false 
    else
      @client.addresses.by_service_address.where(is_default: true).update(is_default: false)
    end
  end

  def set_service_address
    @service_address = @client.addresses.find(params[:id])
  end
end
