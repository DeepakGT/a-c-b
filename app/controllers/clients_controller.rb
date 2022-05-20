require 'will_paginate/array'
class ClientsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
  before_action :set_client, only: %i[show update destroy]

  def index
    clients = filter_by_logged_in_user
    clients = filter_by_location(clients) if params[:default_location_id].present?
    clients = filter_by_status(clients)
    @clients = clients.uniq.sort_by(&:first_name).paginate(page: params[:page])
  end

  def show; end

  def create
    @client = Client.new(client_params)
    @client.save_with_exception_handler
  end

  def update
    @client.update_with_exception_handler(client_params)
  end

  def destroy
    @client.destroy
  end

  private

  def client_params
    params.permit(:first_name, :last_name, :status, :gender, :email, :dob, :clinic_id, :payor_status, :preferred_language, 
      :disqualified, :dq_reason, :bcba_id, :tracking_id, addresses_attributes: 
      %i[id line1 line2 line3 zipcode city state country address_type addressable_type addressable_id],
      phone_number_attributes: %i[phone_type number])
  end

  def set_client
    @client = Client.find(params[:id])
  end

  def authorize_user
    authorize Client if current_user.role_name!='super_admin'
  end

  def filter_by_location(clients)
    location_id = params[:default_location_id]
    clients = clients.by_clinic(location_id)
    clients
  end

  def filter_by_logged_in_user
    if current_user.role_name=='rbt'
      clients = Client.by_staff_id_in_scheduling(current_user.id)
    elsif current_user.role_name=='bcba'
      clients = Client.by_staff_id_in_scheduling(current_user.id).or(Client.by_bcbas(current_user.id))
    else
      clients = Client.all
    end
    clients
  end
  
  def filter_by_status(clients)
    if params[:show_inactive]=="1" || params[:show_inactive]==1
      clients = clients.inactive
    else
      clients = clients.active
    end
    clients
  end
  # end of private

end
