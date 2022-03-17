class StaffMetaDataController < ApplicationController
  before_action :authenticate_user!

  def clients_list
    if current_user.role_name=='bcba' || current_user.role_name=='rbt'
      clinic_ids = current_user.staff_clinics.pluck(:clinic_id) 
      @clients = Client.where(clinic_id: clinic_ids)
    end
  end
end
