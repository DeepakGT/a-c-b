class StaffMetaDataController < ApplicationController
  before_action :authenticate_user!

  def clients_list
    if current_user.role_name=='bcba' || current_user.role_name=='rbt'
      clinic_ids = current_user.staff_clinics.pluck(:clinic_id) 
      clients = Client.where(clinic_id: clinic_ids)
      clients = filter_by_location(clients) if params[:default_location_id].present?
      @clients = clients
    end
  end

  private

  def filter_by_location(clients)
    location_id = params[:default_location_id]
    clients = clients.by_clinic(location_id)
  end
end
