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

  private

  def client_params
    params.permit(:first_name, :last_name, :status, :gender, :email, :dob, :password, :password_confirmation,
                  :clinic_id, contacts_attributes: [:first_name, :last_name, address_attributes:
                  %i[line1 line2 line3 zipcode city state country addressable_type addressable_id], 
                  phone_number_attributes: %i[phone_type number]])
  end

end
