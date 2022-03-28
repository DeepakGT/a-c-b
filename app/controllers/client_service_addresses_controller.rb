class ClientServiceAddressesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client

  def index
    @service_addresses = @client.addresses.by_service_address.order(is_default: :desc)
  end

  private

  def set_client
    @client = Client.find(params[:client_id])
  end
end
