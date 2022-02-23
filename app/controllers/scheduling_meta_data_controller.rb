class SchedulingMetaDataController < ApplicationController
  before_action :authenticate_user!

  def selectable_options
    @selectable_options = get_selectable_options_data
  end

  private

  def get_selectable_options_data
    selectable_options = { clients: Client.all,
                           staff: Staff.all,
                           services: Service.all }
  end
  # end of private

end
