class ClientServiceAddressesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client

  def index
    @service_addresses = @client.addresses.by_service_address.order(is_default: :desc)
  end

  def create
    @service_address = @client.addresses.new(service_address_params)
    @service_address.address_type = 'service_address'
    set_default
    @service_address.save
  end

  private

  def set_client
    @client = Client.find(params[:client_id])
  end

  def service_address_params
    params.permit(:line1, :line2, :line3, :zipcode, :city, :state, :country, :is_default)
  end

  def set_default
    if params[:is_default].to_bool.false?
      @service_address.is_default = false 
    else
      @client.addresses.by_service_address.where(is_default: true).update(is_default: false)
      @service_address.is_default = true 
    end
  end
end
