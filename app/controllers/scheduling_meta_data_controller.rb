class SchedulingMetaDataController < ApplicationController
  before_action :authenticate_user!

  def selectable_options
    @selectable_options = get_selectable_options_data
  end

  def services_list
    staff = Staff.find(params[:staff_id])
    @client_enrollment_services = check_qualifications(params[:client_id], params[:date], staff)
  end

  private

  def get_selectable_options_data
    if params[:clinic_id].present?
      clinic = Clinic.find(params[:clinic_id])
      client = clinic.clients
      staff = clinic.staff
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
