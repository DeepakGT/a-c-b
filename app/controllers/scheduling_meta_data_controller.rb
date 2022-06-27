class SchedulingMetaDataController < ApplicationController
  before_action :authenticate_user!

  def selectable_options
    @selectable_options = selectable_options_data
  end

  def services_list
    if params[:staff_id].present?
      staff = Staff.find(params[:staff_id])
      @client_enrollment_services = check_qualifications(params[:client_id], params[:date], staff)
    else
      @client_enrollment_services = ClientEnrollmentService.left_outer_joins(service: :service_qualifications).by_client(params[:client_id]).by_date(params[:date]).active.by_unassigned_appointments_allowed&.uniq
    end
  end

  def rbt_appointments
    authorize :appointment, :rbt_appointments?
    rbt_schedules = Scheduling.left_outer_joins(:staff, client_enrollment_service: [:service, {client_enrollment: :client}]).by_staff_ids(current_user.id).by_status.with_active_client
    # @upcoming_schedules = rbt_schedules.scheduled_scheduling.order(:date).first(10)
    @todays_appointments = rbt_schedules.todays_schedulings.order(:start_time).last(10)
    past_schedules = rbt_schedules.past_60_days_schedules.unrendered_schedulings.order(date: :desc)
    past_schedules.where(unrendered_reason: []).each do |schedule|
      RenderAppointments::RenderScheduleOperation.call(schedule.id)
    end
    past_schedules = past_schedules.select("schedulings.*, 'Schedule' AS type")
    @past_schedules = past_schedules
    catalyst_data = CatalystData.select("catalyst_data.*,clients.id AS client_id, clients.first_name, clients.last_name,'CatalystData' AS type").joins("LEFT JOIN clients ON (clients.catalyst_patient_id = catalyst_data.catalyst_patient_id)").by_active_clients.after_live_date.past_60_days_catalyst_data.by_catalyst_user_id(current_user.id)
                                 .and((CatalystData.with_no_appointments)).uniq
                                 .first(30)
    @action_items_array = past_schedules.uniq.concat(catalyst_data)
    @action_items_array = sort_action_items(@action_items_array)

    # sql = "(SELECT id, 'Upcoming Schedule' AS type FROM schedulings WHERE staff_id = #{current_user.id} AND status = 'Scheduled' AND date>=CURRENT_TIMESTAMP ORDER BY date LIMIT 10) UNION (SELECT id, 'Past Schedule' AS type FROM schedulings WHERE staff_id = #{current_user.id} AND status = 'Scheduled' AND date<CURRENT_TIMESTAMP AND date>=(CURRENT_TIMESTAMP + INTERVAL '-2 month') AND is_rendered=false ORDER BY date DESC) UNION (SELECT id,'Catalyst Data' AS type FROM catalyst_data WHERE system_scheduling_id IS NULL LIMIT 30);"
    # @appointments = ActiveRecord::Base.connection.exec_query(sql)&.rows
  end

  def bcba_appointments
    authorize :appointment, :bcba_appointments?
    bcba_schedules = Scheduling.left_outer_joins(:staff, client_enrollment_service: [:service, {client_enrollment: :client}]).by_staff_ids(current_user.id).by_status.with_active_client
    # @upcoming_schedules = bcba_schedules.scheduled_scheduling.order(:date).first(10)
    @todays_appointments = bcba_schedules.todays_schedulings.order(:start_time).last(10)
    past_schedules = bcba_schedules.past_60_days_schedules.unrendered_schedulings.order(date: :desc)
    past_schedules.where(unrendered_reason: []).each do |schedule|
      RenderAppointments::RenderScheduleOperation.call(schedule.id)
    end
    past_schedules = past_schedules.select("schedulings.*, 'Schedule' AS type")
    @past_schedules = past_schedules
    @client_enrollment_services = ClientEnrollmentService.by_bcba_ids(current_user.id).excluding_early_codes
                                                         .and(ClientEnrollmentService.about_to_expire.or(ClientEnrollmentService.expired))
                                                         .includes(:client_enrollment, client_enrollment: :client)
    # change_requests = SchedulingChangeRequest.by_approval_status
    # @change_requests = change_requests.by_bcba_ids(current_user.id)
    #                                   .or(change_requests.by_staff_ids(current_user.id)).left_outer_joins(:scheduling)
    catalyst_data = CatalystData.select("catalyst_data.*,clients.id AS client_id, clients.first_name, clients.last_name,'CatalystData' AS type").joins("LEFT JOIN clients ON (clients.catalyst_patient_id = catalyst_data.catalyst_patient_id)").by_active_clients.after_live_date.past_60_days_catalyst_data.by_catalyst_user_id(current_user.id)
                                 .and((CatalystData.with_no_appointments)).uniq
                                 .first(30)
    @action_items_array = past_schedules.uniq.concat(catalyst_data)
    @action_items_array = sort_action_items(@action_items_array)

    # sql = "(SELECT id, 'Upcoming Schedule' AS type FROM schedulings WHERE staff_id = #{current_user.id} AND status = 'Scheduled' AND date>=CURRENT_TIMESTAMP ORDER BY date LIMIT 20) UNION (SELECT id, 'Past Schedule' AS type FROM schedulings WHERE staff_id = #{current_user.id} AND status = 'Scheduled' AND date<CURRENT_TIMESTAMP AND date>=(CURRENT_TIMESTAMP + INTERVAL '-2 month') AND is_rendered=false ORDER BY date DESC) UNION (SELECT client_enrollment_services.id, 'client_enrollment_services' AS type FROM client_enrollment_services INNER JOIN client_enrollments ON client_enrollments.id=client_enrollment_services.client_enrollment_id INNER JOIN clients ON clients.id=client_enrollments.client_id WHERE clients.bcba_id = #{current_user.id} AND client_enrollment_services.end_date >= CURRENT_TIMESTAMP AND client_enrollment_services.end_date <= (CURRENT_TIMESTAMP + INTERVAL '9 day')) UNION (SELECT id,'Catalyst Data' AS type FROM catalyst_data WHERE system_scheduling_id IS NULL LIMIT 30);"
    # @data = ActiveRecord::Base.connection.exec_query(sql)&.rows
  end

  def executive_director_appointments
    authorize :appointment, :executive_director_appointments?
    client_ids = Clinic.find(params[:default_location_id]).clients.active.pluck(:id)
    schedules = Scheduling.left_outer_joins(:soap_notes, :staff, client_enrollment_service: [:service, {client_enrollment: :client}])
    schedules = schedules.by_client_ids(client_ids)
    @todays_appointments = schedules.by_status.todays_schedulings.last(10)
    past_schedules = schedules.by_status.past_60_days_schedules.unrendered_schedulings.order(date: :desc)
    past_schedules.where(unrendered_reason: []).each do |schedule|
      RenderAppointments::RenderScheduleOperation.call(schedule.id)
    end
    past_schedules = past_schedules.select("schedulings.*, 'Schedule' AS type")
    @past_schedules = past_schedules
    @client_enrollment_services = ClientEnrollmentService.by_client(client_ids).excluding_early_codes.and(ClientEnrollmentService.about_to_expire.or(ClientEnrollmentService.expired))
                                                         .includes(:service, :staff, :service_providers, :client_enrollment, client_enrollment: %i[client funding_source]).uniq
    change_requests = SchedulingChangeRequest.by_approval_status
    @change_requests = change_requests.by_client_ids(client_ids)
    catalyst_patient_ids = Client.where(id: client_ids).pluck(:catalyst_patient_id).compact!
    catalyst_data = CatalystData.select("catalyst_data.*,clients.id AS client_id, clients.first_name, clients.last_name,'CatalystData' AS type").joins("LEFT JOIN clients ON (clients.catalyst_patient_id = catalyst_data.catalyst_patient_id)").after_live_date.past_60_days_catalyst_data.by_catalyst_patient_ids(catalyst_patient_ids)
                                 .and((CatalystData.with_no_appointments)).uniq
                                 .first(30)
    @action_items_array = past_schedules.uniq.concat(catalyst_data)
    @action_items_array = sort_action_items(@action_items_array)
    @unassigned_appointments = schedules.scheduled_scheduling.without_staff
  end

  def billing_dashboard
    @authorizations_expire_in_5_days = ClientEnrollmentService.expire_in_5_days.excluding_early_codes
    @authorizations_renewal_in_5_to_20_days = authorization_renewals_in_5_to_20_days
    @authorizations_renewal_in_21_to_60_days = authorization_renewals_in_21_to_60_days
    @client_with_no_authorizations = Client.with_no_authorizations
    @client_with_only_97151_service_authorization = clients_with_only_97151_service_authorization
  end

  def unassigned_catalyst_soap_notes
    if params[:appointment_id].present? && params[:client_id].present?
      schedule = Scheduling.find(params[:appointment_id])
      client = Client.find(params[:client_id])
      @unassigned_notes = CatalystData.where(
        catalyst_patient_id: client.catalyst_patient_id,
        date: schedule.date, 
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
    @services =  Service.order(:name)
  end

  private

  def selectable_options_data
    if params[:location_id].present?
      clinic = Clinic.find(params[:location_id])
      client = clinic.clients.active
      staff = clinic.staff.by_roles(['bcba', 'rbt', 'Clinical Director', 'Lead RBT']).active if !(params[:cross_site_allowed].to_bool.true?)
      staff = Staff.by_roles(['bcba', 'rbt', 'Clinical Director', 'Lead RBT']).active if params[:cross_site_allowed].to_bool.true?
    else
      client = Client.active
      staff = Staff.by_roles(['bcba', 'rbt', 'Clinical Director', 'Lead RBT']).active
    end
    selectable_options = { clients: client.order(:first_name),
                           staff: staff.order(:first_name),
                           services: Service.order(:name) }
  end

  def check_qualifications(client_id, date, staff)
    client_enrollment_services = ClientEnrollmentService.left_outer_joins(service: :service_qualifications).by_client(client_id).by_date(date)
    staff_qualification_ids = staff.qualifications.pluck(:credential_id)
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
    clients = Client.where.not(id: @client_with_no_authorizations.pluck(:id))
    clients_ids = clients.joins(client_enrollments: :client_enrollment_services).where('client_enrollment_services.id': client_enrollment_services_ids).pluck(:id).uniq
    clients = clients.where.not(id: clients_ids)
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
      items.sort_by! {|b| b.type=="Schedule" ? [b.client_enrollment_service.client_enrollment.client.first_name+b.client_enrollment_service.client_enrollment.client.last_name,b.date] : [b.first_name+b.last_name,b.date] }
    elsif params[:sortSoapNoteByClient].present? && !params[:sortSoapNoteByDate].present?
      if params[:sortSoapNoteByClient] == "1" || params[:sortSoapNoteByClient] == 1
        items.sort_by! {|b| b.type=="Schedule" ? b.client_enrollment_service.client_enrollment.client.first_name+b.client_enrollment_service.client_enrollment.client.last_name : b.first_name+b.last_name }
      elsif params[:sortSoapNoteByClient] == "0" || params[:sortSoapNoteByClient] == 0
        items.sort_by! {|b| b.type=="Schedule" ? b.client_enrollment_service.client_enrollment.client.first_name+b.client_enrollment_service.client_enrollment.client.last_name : b.first_name+b.last_name }.reverse!
      end
    elsif !params[:sortSoapNoteByClient].present? && params[:sortSoapNoteByDate].present?
      if params[:sortSoapNoteByDate] == "1" || params[:sortSoapNoteByDate] == 1 
        items.sort_by! &:date
      elsif params[:sortSoapNoteByDate] == "0" || params[:sortSoapNoteByDate] == 0
        items.sort_by!(&:date).reverse!
      end
    end
    items
  end
  # end of private

end
