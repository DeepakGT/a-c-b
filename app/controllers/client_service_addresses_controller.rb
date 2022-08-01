class ClientServiceAddressesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user, only: %i[index show create]
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

  def show
    @service_address
  end

  def update
    authorize @service_address
    set_default if params[:is_default].present?
    @service_address.update(service_address_params)
  end

  def destroy
    authorize @service_address
    @service_address.destroy
  end

  def create_office_address
    @office_address = create_office_address_for_client
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

  def create_office_address_for_client
    office_address = @client.addresses.new(address_name: 'Office', address_type: 'service_address', is_default: false, is_hidden: false)
    if @client.clinic.address.present?
      office_address.line1 = @client.clinic.address.line1
      office_address.line2 = @client.clinic.address.line2
      office_address.line3 = @client.clinic.address.line3
      office_address.city = @client.clinic.address.city
      office_address.state = @client.clinic.address.state
      office_address.country = @client.clinic.address.country
      office_address.zipcode = @client.clinic.address.zipcode
    end
    office_address.save
    office_address
  end

  def authorize_user
    authorize Address if current_user.role_name!='super_admin'
  end
end
