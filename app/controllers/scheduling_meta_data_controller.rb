class SchedulingMetaDataController < ApplicationController
  before_action :authenticate_user!

  def selectable_options
    @selectable_options = get_selectable_options_data
  end

  def services_list
    staff = Staff.find(params[:staff_id])
    @client_enrollment_services = check_qualifications(params[:client_id], params[:date], staff)
  end

  def rbt_appointments
    authorize :appointment, :rbt_appointments?
    rbt_schedules = Scheduling.includes(:staff, client_enrollment_service: [:service, {client_enrollment: :client}]).by_staff_ids(current_user.id).by_status
    # @upcoming_schedules = rbt_schedules.scheduled_scheduling.order(:date).first(10)
    @todays_appointments = rbt_schedules.todays_schedulings.order(:start_time).last(10)
    @past_schedules = rbt_schedules.past_60_days_schedules.unrendered_schedulings.order(date: :desc)
    @catalyst_data = CatalystData.after_live_date.past_60_days_catalyst_data.and(CatalystData.with_multiple_appointments.or(CatalystData.with_no_appointments)).first(30)
    # sql = "(SELECT id, 'Upcoming Schedule' AS type FROM schedulings WHERE staff_id = #{current_user.id} AND status = 'Scheduled' AND date>=CURRENT_TIMESTAMP ORDER BY date LIMIT 10) UNION (SELECT id, 'Past Schedule' AS type FROM schedulings WHERE staff_id = #{current_user.id} AND status = 'Scheduled' AND date<CURRENT_TIMESTAMP AND date>=(CURRENT_TIMESTAMP + INTERVAL '-2 month') AND is_rendered=false ORDER BY date DESC) UNION (SELECT id,'Catalyst Data' AS type FROM catalyst_data WHERE system_scheduling_id IS NULL LIMIT 30);"
    # @appointments = ActiveRecord::Base.connection.exec_query(sql)&.rows
  end

  def bcba_appointments
    authorize :appointment, :bcba_appointments?
    bcba_schedules = Scheduling.includes(:staff, client_enrollment_service: [:service, {client_enrollment: :client}]).by_staff_ids(current_user.id).by_status
    # @upcoming_schedules = bcba_schedules.scheduled_scheduling.order(:date).first(10)
    @todays_appointments = bcba_schedules.todays_schedulings.order(:start_time).last(10)
    @past_schedules = bcba_schedules.past_60_days_schedules.unrendered_schedulings.order(date: :desc)
    @client_enrollment_services = ClientEnrollmentService.by_bcba_ids(current_user.id).and(ClientEnrollmentService.about_to_expire.or(ClientEnrollmentService.expired)).includes(:client_enrollment, client_enrollment: :client)
    # change_requests = SchedulingChangeRequest.by_approval_status
    # @change_requests = change_requests.by_bcba_ids(current_user.id)
    #                                   .or(change_requests.by_staff_ids(current_user.id)).left_outer_joins(:scheduling)
    @catalyst_data = CatalystData.after_live_date.past_60_days_catalyst_data.and(CatalystData.with_multiple_appointments.or(CatalystData.with_no_appointments)).first(30)
    # sql = "(SELECT id, 'Upcoming Schedule' AS type FROM schedulings WHERE staff_id = #{current_user.id} AND status = 'Scheduled' AND date>=CURRENT_TIMESTAMP ORDER BY date LIMIT 20) UNION (SELECT id, 'Past Schedule' AS type FROM schedulings WHERE staff_id = #{current_user.id} AND status = 'Scheduled' AND date<CURRENT_TIMESTAMP AND date>=(CURRENT_TIMESTAMP + INTERVAL '-2 month') AND is_rendered=false ORDER BY date DESC) UNION (SELECT client_enrollment_services.id, 'client_enrollment_services' AS type FROM client_enrollment_services INNER JOIN client_enrollments ON client_enrollments.id=client_enrollment_services.client_enrollment_id INNER JOIN clients ON clients.id=client_enrollments.client_id WHERE clients.bcba_id = #{current_user.id} AND client_enrollment_services.end_date >= CURRENT_TIMESTAMP AND client_enrollment_services.end_date <= (CURRENT_TIMESTAMP + INTERVAL '9 day')) UNION (SELECT id,'Catalyst Data' AS type FROM catalyst_data WHERE system_scheduling_id IS NULL LIMIT 30);"
    # @data = ActiveRecord::Base.connection.exec_query(sql)&.rows
  end

  def executive_director_appointments
    authorize :appointment, :executive_director_appointments?
    client_ids = Clinic.find(params[:default_location_id]).clients.pluck(:id)
    schedules = Scheduling.includes(:soap_notes, :staff, client_enrollment_service: [:service, {client_enrollment: :client}])
    schedules = schedules.by_client_ids(client_ids).by_status
    @todays_appointments = schedules.todays_schedulings.last(10)
    if current_user.role_name=='executive_director' || current_user.role_name=='client_care_coordinator'
      @past_schedules = schedules.past_60_days_schedules.exceeded_24_h_scheduling.unrendered_schedulings.order(date: :desc)
    elsif current_user.role_name=='super_admin' || current_user.role_name=='administrator'
      @past_schedules = schedules.past_60_days_schedules.exceeded_3_days_scheduling.unrendered_schedulings.order(date: :desc)
    end
    @client_enrollment_services = ClientEnrollmentService.by_client(client_ids).and(ClientEnrollmentService.about_to_expire.or(ClientEnrollmentService.expired)).includes(:service, :staff, :service_providers, :client_enrollment, client_enrollment: [:client, :funding_source]).uniq
    change_requests = SchedulingChangeRequest.by_approval_status
    @change_requests = change_requests.by_client_ids(client_ids)
    @catalyst_data = CatalystData.after_live_date.past_60_days_catalyst_data.and(CatalystData.with_multiple_appointments.or(CatalystData.with_no_appointments)).first(30)
  end

  def billing_dashboard
    @authorizations_expire_in_5_days = ClientEnrollmentService.expire_in_5_days
    @authorizations_renewal_in_5_to_20_days = get_authorization_renewals_in_5_to_20_days
    @authorizations_renewal_in_21_to_60_days = get_authorization_renewals_in_21_to_60_days
    @client_with_no_authorizations = Client.with_no_authorizations
    @client_with_only_97151_service_authorization = get_clients_with_only_97151_service_authorization
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

  private

  def get_selectable_options_data
    if params[:location_id].present?
      clinic = Clinic.find(params[:location_id])
      client = clinic.clients.active
      staff = clinic.staff.by_roles(['bcba', 'rbt']).active if !(params[:cross_site_allowed].to_bool.true?)
      staff = Staff.by_roles(['bcba', 'rbt']).active if params[:cross_site_allowed].to_bool.true?
    else
      client = Client.active
      staff = Staff.by_roles(['bcba', 'rbt']).active
    end
    selectable_options = { clients: client.order(:first_name),
                           staff: staff.order(:first_name),
                           services: Service.order(:name) }
  end

  def check_qualifications(client_id, date, staff)
    client_enrollment_services = ClientEnrollmentService.left_outer_joins(service: :service_qualifications).by_client(params[:client_id]).by_date(params[:date])
    staff_qualification_ids = staff.qualifications.pluck(:credential_id)
    if staff_qualification_ids.blank?
      client_enrollment_services = client_enrollment_services.by_service_with_no_qualification
    else
      client_enrollment_services = client_enrollment_services.by_service_with_no_qualification
                                                             .or(client_enrollment_services.by_staff_qualifications(staff_qualification_ids))
                                                          
    end
    client_enrollment_services&.uniq
  end

  def get_clients_with_only_97151_service_authorization
    client_enrollment_services_ids = ClientEnrollmentService.joins(:service).where('services.display_code != ?', '97151').pluck(:id)
    clients = Client.where.not(id: @client_with_no_authorizations.pluck(:id))
    clients_ids = clients.joins(client_enrollments: :client_enrollment_services).where('client_enrollment_services.id': client_enrollment_services_ids).pluck(:id).uniq
    clients = clients.where.not(id: clients_ids)
    clients
  end

  def get_authorization_renewals_in_5_to_20_days
    client_enrollment_services = ClientEnrollmentService.started_between_5_to_20_days_past_from_today.active
    client_enrollment_services = get_authorization_renewals(client_enrollment_services)
  end

  def get_authorization_renewals_in_21_to_60_days
    client_enrollment_services = ClientEnrollmentService.started_between_21_to_60_days_past_from_today.active
    client_enrollment_services = get_authorization_renewals(client_enrollment_services)
  end

  def get_authorization_renewals(client_enrollment_services)
    return client_enrollment_services if client_enrollment_services.blank?

    client_enrollment_services = client_enrollment_services.map{|client_enrollment_service| client_enrollment_service if ClientEnrollmentService.by_client(client_enrollment_service.client_enrollment.client_id).by_funding_source(client_enrollment_service.client_enrollment&.funding_source_id).by_service(client_enrollment_service.service_id).except_self(client_enrollment_service.id).before_date(client_enrollment_service.start_date).present?}
    client_enrollment_services.compact!
  end
  # end of private

end
