class CatalystController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user

  def sync_with_catalyst
    @response_data_array = Catalyst::SyncDataOperation.call(params[:start_date], params[:end_date])
  end

  private

  def authorize_user
    authorize Catalyst if current_user.role_name!='super_admin'
  end
end
