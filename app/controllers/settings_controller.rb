class SettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
  before_action :set_setting

  def show
    @setting
  end

  def update 
    #TODO: A quick fix for this problem is made, the whole role system will have to be refactored.
    super_admin_role_id = Role.find_by(name: 'super_admin').id
    params[:roles_ids] << super_admin_role_id if super_admin_role_id
    @setting.update(update_params)
  end

  private

  def update_params
    params.permit(:welcome_note, roles_ids:[])
  end

  def set_setting
    @setting = Setting.first
  end

  def authorize_user
    authorize Setting if current_user.role_name!='super_admin'
  end
end
