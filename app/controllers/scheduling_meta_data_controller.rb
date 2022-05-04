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
    rbt_schedules = Scheduling.by_staff_ids(current_user.id).by_status
    @upcoming_schedules = rbt_schedules.scheduled_scheduling.order(:date).first(10)
    @past_schedules = rbt_schedules.completed_scheduling.unrendered_schedulings.order(date: :desc)
    @catalyst_data = CatalystData.with_multiple_appointments.or(CatalystData.with_no_appointments).first(30)
    # sql = "SELECT id, 'Upcoming Schedule' AS type FROM schedulings WHERE staff_id = #{current_user.id} AND date>=CURRENT_TIMESTAMP UNION SELECT id, 'Past Schedule' AS type FROM schedulings WHERE staff_id = #{current_user.id} AND date<CURRENT_TIMESTAMP AND is_rendered=false UNION SELECT id,'Catalyst Data' AS type FROM catalyst_data WHERE is_appointment_found=false OR cardinality(multiple_schedulings_ids)>0"
    # @appointments = ActiveRecord::Base.connection.exec_query(sql)&.rows
  end

  def bcba_appointments
    authorize :appointment, :bcba_appointments?
    bcba_schedules = Scheduling.by_staff_ids(current_user.id).by_status
    @upcoming_schedules = bcba_schedules.scheduled_scheduling.order(:date).first(10)
    @past_schedules = bcba_schedules.completed_scheduling.unrendered_schedulings.order(date: :desc)
    @client_enrollment_services = ClientEnrollmentService.by_bcba_ids(current_user.id).about_to_expire
    change_requests = SchedulingChangeRequest.by_approval_status
    @change_requests = change_requests.by_bcba_ids(current_user.id)
                                      .or(change_requests.by_staff_ids(current_user.id)).left_outer_joins(:scheduling)
    @catalyst_data = CatalystData.with_multiple_appointments.or(CatalystData.with_no_appointments).first(30)
  end

  def executive_director_appointments
    authorize :appointment, :executive_director_appointments?
    client_ids = Clinic.find(params[:default_location_id]).clients.pluck(:id)
    schedules = Scheduling.by_client_ids(client_ids).by_status
    @todays_appointments = schedules.todays_schedulings.order(:start_time).last(10)
    if current_user.role_name=='executive_director' || current_user.role_name=='client_care_coordinator'
      @past_schedules = schedules.exceeded_24_h_scheduling.unrendered_schedulings.order(date: :desc)
    elsif current_user.role_name=='super_admin' || current_user.role_name=='administrator'
      @past_schedules = schedules.exceeded_3_days_scheduling.unrendered_schedulings.order(date: :desc)
    end
    @client_enrollment_services = ClientEnrollmentService.by_client(client_ids).about_to_expire
    change_requests = SchedulingChangeRequest.by_approval_status
    @change_requests = change_requests.by_client_ids(client_ids)
    @catalyst_data = CatalystData.with_multiple_appointments.or(CatalystData.with_no_appointments).first(30)
  end

  def billing_dashboard
    @authorizations_expire_in_5_days = ClientEnrollmentService.expire_in_5_days
    @authorizations_expire_in_6_to_20_days = ClientEnrollmentService.expire_in_6_to_20_days
    @authorizations_expire_in_21_to_60_days = ClientEnrollmentService.expire_in_21_to_60_days
    @client_with_no_authorizations = Client.with_no_authorizations
    @client_with_only_97151_service_authorization = get_clients_with_only_97151_service_authorization
  end

  private

  def get_selectable_options_data
    if params[:location_id].present?
      clinic = Clinic.find(params[:location_id])
      client = clinic.clients
      staff = clinic.staff.by_roles(['bcba', 'rbt']) if !(params[:cross_site_allowed].to_bool.true?)
      staff = Staff.by_roles(['bcba', 'rbt']) if params[:cross_site_allowed].to_bool.true?
    else
      client = Client.all
      staff = Staff.by_roles(['bcba', 'rbt'])
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
  # end of private

end
