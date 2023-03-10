require 'will_paginate/array'
SCHEDULE_QUERY = "schedulings.*, 'Schedule' AS type".freeze
CATALYST_QUERY = "catalyst_data.*,clients.id AS client_id, clients.first_name AS first_name, clients.last_name AS last_name,'CatalystData' AS type".freeze
CATALYST_LEFT_JOIN_QUERY = "LEFT JOIN clients ON (clients.catalyst_patient_id = catalyst_data.catalyst_patient_id)".freeze
CATALYST_LEFT_JOIN_WITH_CLINIC = "LEFT JOIN clinics ON (clinics.id = clients.clinic_id)".freeze
SCHEDULING_ROLES = ['bcba', 'rbt', 'Clinical Director', 'Lead RBT'].freeze

class SchedulingMetaDataController < ApplicationController
  before_action :authenticate_user!

  def selectable_options
    @selectable_options = selectable_options_data
  end

  def services_list
    if params[:staff_id].present?
      @staff = Staff.find(params[:staff_id]) rescue nil
      @client_enrollment_services = check_qualifications(params[:client_id], params[:date], @staff)
    else
      @client_enrollment_services = ClientEnrollmentService.left_outer_joins(service: :service_qualifications).by_client(params[:client_id]).by_date(params[:date]).active.by_unassigned_appointments_allowed&.uniq
    end
  end

  def rbt_appointments
    authorize :appointment, :rbt_appointments?
    rbt_schedules = Scheduling.left_outer_joins(:staff, client_enrollment_service: [:service, {client_enrollment: :client}]).joins("LEFT JOIN clinics ON (clinics.id = clients.clinic_id)").by_staff_ids(current_user.id).by_status
    @todays_appointments = rbt_schedules.todays_schedulings&.order(:start_time)&.last(10)
    past_schedules = rbt_schedules.post_30_may_schedules.unrendered_schedulings&.order(date: :desc)
    past_schedules.where(unrendered_reason: [])&.each do |schedule|
      RenderAppointments::RenderScheduleOperation.call(schedule&.id)
    end
    past_schedules = past_schedules&.select(SCHEDULE_QUERY)
    @past_schedules = past_schedules
    catalyst_data = CatalystData.select(CATALYST_QUERY).joins(CATALYST_LEFT_JOIN_QUERY).joins(CATALYST_LEFT_JOIN_WITH_CLINIC).post_30_may_catalyst_data.by_catalyst_user_id(current_user.id).removed_from_dashboard.and(CatalystData.with_no_appointments).uniq
    @action_items_array = past_schedules&.uniq&.concat(catalyst_data)
    @total_count = @action_items_array.length
    @action_items_array = filter_by_client(@action_items_array) if params[:client_name].present?
    @action_items_array = sort_action_items(@action_items_array)
    @action_items_array = @action_items_array&.paginate(page: params[:page]) if params[:page].present?
  end

  def bcba_appointments
    authorize :appointment, :bcba_appointments?
    bcba_schedules = Scheduling.left_outer_joins(:staff, client_enrollment_service: [:service, {client_enrollment: :client}]).joins("LEFT JOIN clinics ON (clinics.id = clients.clinic_id)").by_staff_ids(current_user.id).by_status
    @todays_appointments = bcba_schedules.todays_schedulings&.order(:start_time)&.last(10)
    past_schedules = bcba_schedules.post_30_may_schedules.unrendered_schedulings&.order(date: :desc)
    past_schedules.where(unrendered_reason: []).each do |schedule|
      RenderAppointments::RenderScheduleOperation.call(schedule&.id)
    end
    past_schedules = past_schedules&.select(SCHEDULE_QUERY)
    @past_schedules = past_schedules
    @client_enrollment_services = ClientEnrollmentService.by_bcba_ids(current_user.id).joins(:service).excluding_early_codes
                                                         .and(ClientEnrollmentService.about_to_expire.or(ClientEnrollmentService.expired))
                                                         .includes(:client_enrollment, client_enrollment: :client)
    catalyst_data = CatalystData.select(CATALYST_QUERY).joins(CATALYST_LEFT_JOIN_QUERY).joins(CATALYST_LEFT_JOIN_WITH_CLINIC).post_30_may_catalyst_data.by_catalyst_user_id(current_user.id).removed_from_dashboard.and(CatalystData.with_no_appointments).uniq
    @action_items_array = past_schedules&.uniq&.concat(catalyst_data)
    @total_count = @action_items_array.length
    @action_items_array = filter_by_client(@action_items_array) if params[:client_name].present?
    @action_items_array = sort_action_items(@action_items_array)
    @action_items_array = @action_items_array&.paginate(page: params[:page]) if params[:page].present?
  end

  def executive_director_appointments
    authorize :appointment, :executive_director_appointments?
    client_ids = Clinic.find_by(id: params[:default_location_id])&.clients&.pluck(:id)
    schedules = Scheduling.left_outer_joins(:soap_notes, :staff, client_enrollment_service: [:service, {client_enrollment: :client}])
    schedules = schedules.joins("LEFT JOIN clinics ON (clinics.id = clients.clinic_id)").by_client_ids(client_ids)
    @todays_appointments = schedules.by_status.todays_schedulings&.last(10)
    past_schedules = schedules.by_status.post_30_may_schedules.unrendered_schedulings&.order(date: :desc)
    past_schedules&.where(unrendered_reason: []).each do |schedule|
      RenderAppointments::RenderScheduleOperation.call(schedule&.id)
    end
    past_schedules = past_schedules&.select(SCHEDULE_QUERY)
    @past_schedules = past_schedules
    @client_enrollment_services = ClientEnrollmentService.by_client(client_ids).joins(:service).excluding_early_codes.and(ClientEnrollmentService.about_to_expire.or(ClientEnrollmentService.expired))
                                                         .includes(:service, :staff, :service_providers, :client_enrollment, client_enrollment: %i[client funding_source]).uniq
    change_requests = SchedulingChangeRequest.by_approval_status
    @change_requests = change_requests&.by_client_ids(client_ids)
    catalyst_patient_ids = Client.where(id: client_ids).pluck(:catalyst_patient_id).compact
    catalyst_data = CatalystData.select(CATALYST_QUERY).joins(CATALYST_LEFT_JOIN_QUERY).joins(CATALYST_LEFT_JOIN_WITH_CLINIC).post_30_may_catalyst_data.by_catalyst_patient_ids(catalyst_patient_ids).removed_from_dashboard.and(CatalystData.with_no_appointments).uniq
    @action_items_array = past_schedules&.uniq&.concat(catalyst_data)
    @total_count = @action_items_array&.length
    @action_items_array = filter_by_client(@action_items_array) if params[:client_name].present?
    @action_items_array = sort_action_items(@action_items_array) if @action_items_array.present?
    @action_items_array = @action_items_array&.paginate(page: params[:page]) if params[:page].present?
    @unassigned_appointments = schedules&.scheduled_scheduling&.without_staff
  end

  def billing_dashboard
    @authorizations_expire_in_5_days = ClientEnrollmentService.expire_in_5_days.joins(:service).excluding_early_codes
    @authorizations_renewal_in_5_to_20_days = authorization_renewals_in_5_to_20_days
    @authorizations_renewal_in_21_to_60_days = authorization_renewals_in_21_to_60_days
    @client_with_no_authorizations = Client.with_no_authorizations
    @client_with_only_97151_service_authorization = clients_with_only_97151_service_authorization
  end

  def unassigned_catalyst_soap_notes
    if params[:appointment_id].present? && params[:client_id].present?
      schedule = Scheduling.find(params[:appointment_id]) rescue nil
      client = Client.find(params[:client_id]) rescue nil
      @unassigned_notes = CatalystData.where(
        catalyst_patient_id: client&.catalyst_patient_id,
        date: schedule&.date, 
        system_scheduling_id: nil
      ).all  
    end
  end

  def clients_and_staff_list_for_filter
    case current_user.role_name
    when 'rbt', 'bcba'
      clients = Client.by_staff_id_in_scheduling(current_user.id).or(Client.by_clinic(params[:location_id]))
    else
      clients = Client.by_clinic(params[:location_id])
    end
    @clients = clients&.active&.uniq&.sort_by(&:first_name)
    @staff = Staff.by_home_clinic(params[:location_id]).active
    @services = Service.order(:name)
  end

  private

  def selectable_options_data
    if params[:location_id].present?
      clinic = Clinic.find(params[:location_id]) rescue nil
      client = clinic&.clients&.active
      staff = clinic&.staff&.by_roles(SCHEDULING_ROLES).active if !(params[:cross_site_allowed].to_bool.true?)
      staff = Staff.by_roles(SCHEDULING_ROLES).active if params[:cross_site_allowed].to_bool.true?
    else
      client = Client.active
      staff = Staff.by_roles(SCHEDULING_ROLES).active
    end
    return { clients: client&.order(:first_name),
                           staff: staff&.order(:first_name),
                           services: Service.order(:name) }
  end

  def check_qualifications(client_id, date, staff)
    client_enrollment_services = ClientEnrollmentService.left_outer_joins(service: :service_qualifications).by_client(client_id).by_date(date)
    staff_qualification_ids = staff&.qualifications&.pluck(:credential_id)
    if staff_qualification_ids.blank?
      client_enrollment_services = client_enrollment_services.by_service_with_no_qualification
    else
      client_enrollment_services = client_enrollment_services.by_service_with_no_qualification
                                                             .or(client_enrollment_services.by_staff_qualifications(staff_qualification_ids))
                                                          
    end
    client_enrollment_services&.uniq
  end

  def clients_with_only_97151_service_authorization
    client_enrollment_services_ids = ClientEnrollmentService.joins(:service).where('services.display_code != ?', '97151').pluck(:id)
    clients = Client.where.not(id: @client_with_no_authorizations&.pluck(:id))
    clients_ids = clients.joins(client_enrollments: :client_enrollment_services).where('client_enrollment_services.id': client_enrollment_services_ids).pluck(:id).uniq
    clients = clients&.where.not(id: clients_ids)
  end

  def authorization_renewals_in_5_to_20_days
    client_enrollment_services = ClientEnrollmentService.started_between_5_to_20_days_past_from_today.active
    client_enrollment_services = authorization_renewals(client_enrollment_services)
  end

  def authorization_renewals_in_21_to_60_days
    client_enrollment_services = ClientEnrollmentService.started_between_21_to_60_days_past_from_today.active
    client_enrollment_services = authorization_renewals(client_enrollment_services)
  end

  def authorization_renewals(client_enrollment_services)
    return client_enrollment_services if client_enrollment_services.blank?

    client_enrollment_services = client_enrollment_services.map do |client_enrollment_service|
      authorizations = ClientEnrollmentService.by_client(client_enrollment_service.client_enrollment.client_id).by_funding_source(client_enrollment_service.client_enrollment&.funding_source_id)
                                              .by_service(client_enrollment_service.service_id).except_self(client_enrollment_service.id).before_date(client_enrollment_service.start_date)
      client_enrollment_service if authorizations.present?
    end
    client_enrollment_services.compact!
  end

  def sort_action_items(items)
    if params[:sortSoapNoteByClient].present? && params[:sortSoapNoteByDate].present?
      items&.sort_by! {|b| b&.type=="Schedule" ? [b&.client_enrollment_service&.client_enrollment&.client&.first_name+b&.client_enrollment_service&.client_enrollment&.client&.last_name,b&.date] : [b&.first_name+b&.last_name,b&.date] }
    elsif params[:sortSoapNoteByClient].present? && !params[:sortSoapNoteByDate].present?
      sort_soap_note_by_client(items)
    elsif !params[:sortSoapNoteByClient].present? && params[:sortSoapNoteByDate].present?
      sort_soap_note_by_date(items)
    end
    items
  end

  def sort_soap_note_by_client(items)
    case params[:sortSoapNoteByClient]
    when "1", 1
      items.sort_by! {|b| b&.type=="Schedule" ? b&.client_enrollment_service&.client_enrollment&.client&.first_name+b&.client_enrollment_service&.client_enrollment&.client&.last_name : b&.first_name+b&.last_name }
    when "0", 0
      items.sort_by! {|b| b&.type=="Schedule" ? b&.client_enrollment_service&.client_enrollment&.client&.first_name+b&.client_enrollment_service&.client_enrollment&.client&.last_name : b&.first_name+b&.last_name }&.reverse!
    else
      items
    end
    items
  end

  def sort_soap_note_by_date(items)
    case params[:sortSoapNoteByDate]
    when "1", 1
      items&.sort_by!(&:date)
    when "0", 0
      items&.sort_by!(&:date)&.reverse!
    else
      items
    end
    items
  end

  def filter_by_client(items)
    fname, lname = params[:client_name]&.split(' ')
    if fname.present? && lname.blank?
      clients = Client.by_first_name(fname).or(Client.by_last_name(fname))
    elsif fname.present? && lname.present?
      clients = Client.by_first_name(fname)
      clients = clients.by_last_name(lname)
    else
      clients = Client.by_first_name(fname)
      clients = clients.by_last_name(lname)
    end
    client_ids = clients&.pluck(:id)&.uniq&.compact
    catalyst_patient_ids = clients&.pluck(:catalyst_patient_id)&.uniq&.compact
    items = items&.map{|item| item if ((item&.type=='Schedule' && client_ids&.include?(item&.client_enrollment_service&.client_enrollment&.client_id)) || (item&.type=='CatalystData' && catalyst_patient_ids&.include?(item&.catalyst_patient_id)))}.uniq.compact if clients.present?
  end
  # end of private
end
