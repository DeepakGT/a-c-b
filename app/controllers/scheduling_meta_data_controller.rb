class SchedulingMetaDataController < ApplicationController
  before_action :authenticate_user!

  def selectable_options
    @selectable_options = get_selectable_options_data
  end

  private

  def get_selectable_options_data
    selectable_options = { clients: Client.order(:first_name),
                           staff: Staff.order(:first_name),
                           services: Service.order(:name) }
  end
  # end of private

end
