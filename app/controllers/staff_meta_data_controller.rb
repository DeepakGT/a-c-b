class StaffMetaDataController < ApplicationController
  before_action :authenticate_user!

  def clients_list
    case current_user.role_name
    when 'rbt'
      clients = Client.by_staff_id_in_scheduling(current_user.id).with_appointment_after_last_30_days
      clients = filter_by_location(clients) if params[:default_location_id].present?
      @clients = clients&.uniq&.sort_by(&:id)
    when 'bcba'
      clients = Client.by_staff_id_in_scheduling(current_user.id).with_appointment_after_last_30_days.or(Client.by_bcbas(current_user.id))
      clients = filter_by_location(clients) if params[:default_location_id].present?
      @clients = clients&.uniq&.sort_by(&:id)
    else
      puts "clinics_list"
    end
  end

  private

  def filter_by_location(clients)
    location_id = params[:default_location_id]
    clients = clients.by_clinic(location_id)
  end
end
