require 'will_paginate/array'
class ClientsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user, except: :past_appointments
  before_action :set_client, only: %i[show update destroy]
  before_action :remove_trailing_space, only: %i[create update]

  def index
    clients = filter_by_logged_in_user
    clients = filter_by_status(clients)
    clients = do_filter(clients) if params[:search_value].present?
    clients = filter_by_location(clients)
    @clients = clients&.uniq&.sort_by(&:first_name)
    @clients = @clients&.paginate(page: params[:page]) if params[:page].present?
  end

  def show
    @client
  end

  def create
    @client = Client.new(client_params)
    @client&.save_with_exception_handler
    create_office_address_for_client if !@client.id.nil?
  end

  def update
    @client&.update_with_exception_handler(client_params)
  end

  def destroy
    SoapNote.by_client(@client&.id)&.destroy_all
    @client&.destroy
  end

  def past_appointments
    @client = Client.find(params[:client_id]) rescue nil
    @schedules = Scheduling.joins(client_enrollment_service: :client_enrollment).by_client_ids(@client&.id).completed_scheduling
    @schedules = filter_schedules(@schedules) if params[:staff_ids].present? || params[:service_ids].present?
    @schedules = @schedules.paginate(page: params[:page]) if params[:page].present?
  end

  private

  def client_params
    params.permit(:first_name, :last_name, :status, :gender, :email, :dob, :clinic_id, :payor_status, :preferred_language, 
                  :disqualified, :dq_reason, :primary_bcba_id, :secondary_bcba_id, :primary_rbt_id, :secondary_rbt_id, :tracking_id, addresses_attributes: 
                  %i[id line1 line2 line3 zipcode city state country address_type addressable_type addressable_id],
                  phone_number_attributes: %i[phone_type number])
  end

  def set_client
    @client = Client.find(params[:id]) rescue nil
  end

  def authorize_user
    authorize Client if current_user.role_name!='super_admin'
  end

  def create_office_address_for_client
    office_address = @client&.addresses&.new(address_name: 'Office', address_type: 'service_address', is_default: false, is_hidden: false)
    if @client&.clinic&.address.present?
      office_address.line1 = @client.clinic.address.line1
      office_address.line2 = @client.clinic.address.line2
      office_address.line3 = @client.clinic.address.line3
      office_address.city = @client.clinic.address.city
      office_address.state = @client.clinic.address.state
      office_address.country = @client.clinic.address.country
      office_address.zipcode = @client.clinic.address.zipcode
    end
    office_address&.save
  end

  def filter_by_location(clients)
    if params[:default_location_id].present? && params[:search_cross_location]!=1 && params[:search_cross_location]!="1" 
      location_id = params[:default_location_id]
      clients = clients.by_clinic(location_id)
    end
    clients
  end

  def filter_by_logged_in_user
    case current_user.role_name
    when 'rbt'
      clients = Client.by_staff_id_in_scheduling(current_user.id).with_appointment_after_last_30_days
    when 'bcba'
      clients = Client.by_staff_id_in_scheduling(current_user.id).with_appointment_after_last_30_days.or(Client.by_bcbas(current_user.id))
    else
      clients = Client.all
    end
    clients
  end
  
  def filter_by_status(clients)
    if clients.present?
      if params[:show_inactive]=="1" || params[:show_inactive]==1
        clients = clients.inactive
      else
        clients = clients.active
      end
    end
    clients
  end

  def do_filter(clients)
    if params[:search_by].present?
      case params[:search_by]
      when "name"
        names = params[:search_value].split(' ')
        names.each do |name|
          clients = clients.by_first_name(name).or(clients.by_last_name(name))
        end
        return clients
      when "gender"
        gender_value = params[:search_value]&.downcase
        clients.by_gender(gender_value)
      when "payor_status"
        clients.by_payor_status(params[:search_value]&.downcase)
      when "bcba"
        names = params[:search_value].split
        names.each do |name|
          clients = clients.by_bcba_first_name(name).or(clients.by_bcba_last_name(name))
        end
        return clients
      when "payor"
        clients.by_payor(params[:search_value])
      else
        clients
      end
    else
      clients = search_on_all_fields(params[:search_value], clients)
    end
  end

  def search_on_all_fields(query, clients)
    query = query&.downcase
    names = query.split
    names.each do |name|
      clients = clients.by_payor(query)
                       .or(clients.by_first_name(name))
                       .or(clients.by_last_name(name))
                       .or(clients.by_gender(name))
                       .or(clients.by_payor_status(name))
                       .or(clients.by_bcba_first_name(name))
                       .or(clients.by_bcba_last_name(name))
    end
    clients
  end

  def remove_trailing_space
    params[:first_name].strip! if params[:first_name].present?
    params[:last_name].strip! if params[:last_name].present?
  end

  def filter_schedules(schedules)
    schedules = schedules.by_staff_ids(params[:staff_ids]) if params[:staff_ids].present?
    schedules = schedules.by_service_ids(params[:service_ids]) if params[:service_ids].present?
    schedules
  end
  # end of private
end
