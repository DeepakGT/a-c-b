class SchedulingMetaDataController < ApplicationController
  before_action :authenticate_user!

  def selectable_options
    @selectable_options = get_selectable_options_data
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
