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
    if current_user.role_name=='rbt'
      rbt_schedules = Scheduling.by_staff_ids(current_user.id)
      @upcoming_schedules = rbt_schedules.scheduled_scheduling.order(:date)
      @past_schedules = rbt_schedules.completed_scheduling.where(is_rendered: false).order(date: :desc)
    end
  end

  def bcba_appointments
    if current_user.role_name=='bcba'
      bcba_schedules = Scheduling.by_staff_ids(current_user.id)
      @upcoming_schedules = bcba_schedules.scheduled_scheduling.order(:date)
      @past_schedules = bcba_schedules.completed_scheduling.where(is_rendered: false).order(date: :desc)
      @client_enrollment_services = ClientEnrollmentService.joins(client_enrollment: :client).where('users.bcba_id': current_user.id)
                                                           .where('end_date>=? AND end_date<=?', Time.now.to_date, (Time.now.to_date+9))
    end
  end

  private

  def get_selectable_options_data
    if params[:location_id].present?
      clinic = Clinic.find(params[:location_id])
      client = clinic.clients
      staff = clinic.staff if !(params[:cross_site_allowed].to_bool.true?)
      staff = Staff.all if params[:cross_site_allowed].to_bool.true?
    else
      client = Client.all
      staff = Staff.all
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
