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
    rbt_schedules = Scheduling.by_staff_ids(current_user.id)
    @upcoming_schedules = rbt_schedules.scheduled_scheduling.order(:date)
    @past_schedules = rbt_schedules.completed_scheduling.where(is_rendered: false).order(date: :desc)
  end

  def bcba_appointments
    authorize :appointment, :bcba_appointments?
    bcba_schedules = Scheduling.by_staff_ids(current_user.id)
    @upcoming_schedules = bcba_schedules.scheduled_scheduling.order(:date)
    @past_schedules = bcba_schedules.completed_scheduling.unrendered_schedulings.order(date: :desc)
    @client_enrollment_services = ClientEnrollmentService.by_bcba_ids(current_user.id).about_to_expire
    change_requests = SchedulingChangeRequest.by_approval_status
    @change_requests = change_requests.by_bcba_ids(current_user.id)
                                      .or(change_requests.by_staff_ids(current_user.id)).left_outer_joins(:scheduling)
  end

  def aba_admin_appointments
    authorize :appointment, :aba_admin_appointments?
    client_ids = Clinic.find(params[:default_location_id]).clients.pluck(:id)
    schedules = Scheduling.by_client_ids(client_ids)
    @todays_appointments = schedules.todays_schedulings
    @past_schedules = schedules.completed_scheduling.unrendered_schedulings.order(date: :desc)
    @client_enrollment_services = ClientEnrollmentService.by_client(client_ids).about_to_expire
    change_requests = SchedulingChangeRequest.by_approval_status
    @change_requests = change_requests.by_client_ids(client_ids)
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
    client_enrollment_services = client_enrollment_services.by_service_with_no_qualification
                                                           .or(client_enrollment_services.by_staff_qualifications(staff_qualification_ids))
  end
  # end of private

end
