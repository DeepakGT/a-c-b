class ClientServiceAddressesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user, only: %i[index show create update destroy]
  before_action :set_client
  before_action :set_service_address, only: %i[show update destroy]

  def index
    @service_addresses = @client&.addresses&.by_service_address&.order(is_default: :desc)
  end

  def create
    @service_address = @client.addresses.build(service_address_params)
    @service_address.address_type = 'service_address'
    set_default if @service_address.is_default.present?
    @service_address.save
  end

  def show; end

  def update
    @service_address.assign_attributes(service_address_params)
    set_default if @service_address.is_default_changed?
    if @service_address.save
      @service_address
    else
      unprosessable_entity_response(@service_address)
    end
  end

  def destroy
    @service_address.destroy
  end

  def create_office_address
    @office_address = @client.create_office_address_for_client
  end

  private

  def set_client
    @client = Client.find(params[:client_id]) rescue nil
  end

  def service_address_params
    params.permit(:line1, :line2, :line3, :zipcode, :city, :state, :country, :is_default, :is_hidden, :service_address_type_id)
  end

  def set_default
    return true unless @client.addresses.by_service_address.present?

    @client.addresses.by_service_address.where(is_default: true).update_all(is_default: false)
  end

  def set_service_address
    @service_address = @client&.addresses&.find(params[:id]) rescue nil
  end

  def authorize_user
    authorize Address if current_user.role_name != 'super_admin'
  end
end
