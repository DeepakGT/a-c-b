class SchedulingMetaDataController < ApplicationController
  before_action :authenticate_user!

  def selectable_options
    @selectable_options = get_selectable_options_data
  end

  def services_list
    client_enrollment_services = ClientEnrollmentService.by_client(params[:client_id]).by_date(params[:date])
    @client_enrollment_services = client_enrollment_services.by_staff(params[:staff_id])
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
  # end of private

end
