require 'will_paginate/array'
class ClientsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user, except: %i[soap_notes_pdf past_appointments]
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
    @client.create_office_address_for_client if @client.present?
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

  def soap_notes_pdf
    @client = Client.find(soap_notes_pdf_params[:client_id]) rescue nil
    @soap_notes = SoapNote.by_client(@client&.id)
    @soap_notes = soap_notes_pdf_params[:soap_notes_ids].present? ? @soap_notes.by_ids(soap_notes_pdf_params[:soap_notes_ids]) : @soap_notes
    job = GeneratePdfWorker.perform_in(30.seconds, @client&.id, @soap_notes&.ids, current_user&.id)
    @success =  Sidekiq::ScheduledSet.new.map{|job| job['jid']}.include?(job) ? true : false
  end

  private

  def client_params
    params.permit(:first_name, :last_name, :status, :gender, :email, :dob, :clinic_id, :payor_status, :preferred_language, 
                  :disqualified, :dq_reason, :primary_bcba_id, :secondary_bcba_id, :primary_rbt_id, :secondary_rbt_id, :tracking_id, addresses_attributes: 
                  %i[id line1 line2 line3 zipcode city state country address_type addressable_type addressable_id],
                  phone_number_attributes: %i[phone_type number])
  end

  def soap_notes_pdf_params
    params.permit(:client_id, :soap_notes_ids)
  end

  def set_client
    @client = Client.find(params[:id]) rescue nil
  end

  def authorize_user
    authorize Client if current_user.role_name!='super_admin'
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
end
